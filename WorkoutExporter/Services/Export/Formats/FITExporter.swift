import Foundation
import HealthKit

struct FITExporter: ExportableFormat {
    let format = ExportFormat.fit

    func export(workout: WorkoutData) throws -> Data {
        let encoder = FITEncoder()

        // 1. File header
        encoder.writeFileHeader()

        // 2. File ID message (local type 0)
        writeFileId(encoder: encoder, workout: workout)

        // 3. Event message: timer start (local type 1)
        writeEvent(encoder: encoder, timestamp: workout.startDate, eventType: 0) // 0 = start

        // 4. Record messages (local type 2) — one per data point
        writeRecords(encoder: encoder, workout: workout)

        // 5. Lap message (local type 3)
        writeLap(encoder: encoder, workout: workout)

        // 6. Session message (local type 4)
        writeSession(encoder: encoder, workout: workout)

        // 7. Event message: timer stop (local type 1, reuse definition)
        writeEventData(encoder: encoder, timestamp: workout.endDate, eventType: 4) // 4 = stop_all

        // 8. Activity message (local type 5)
        writeActivity(encoder: encoder, workout: workout)

        return encoder.finalize()
    }

    // MARK: - File ID

    private func writeFileId(encoder: FITEncoder, workout: WorkoutData) {
        let definition = FITDefinitionMessage(
            localMessageType: 0,
            globalMessageNumber: FITMessageType.fileId.rawValue,
            fields: [
                FITFileIdFields.type,
                FITFileIdFields.manufacturer,
                FITFileIdFields.product,
                FITFileIdFields.serialNumber,
                FITFileIdFields.timeCreated,
            ]
        )
        encoder.writeDefinitionMessage(definition)

        var msg = FITDataMessage(localMessageType: 0)
        msg.appendUInt8(4)                                          // type = activity
        msg.appendUInt16(255)                                       // manufacturer = development
        msg.appendUInt16(0)                                         // product
        msg.appendUInt32(UInt32(workout.startDate.timeIntervalSince1970) & 0xFFFF) // serial number
        msg.appendUInt32(fitTimestamp(from: workout.startDate))     // time_created
        encoder.writeDataMessage(msg)
    }

    // MARK: - Event

    private func writeEvent(encoder: FITEncoder, timestamp: Date, eventType: UInt8) {
        let definition = FITDefinitionMessage(
            localMessageType: 1,
            globalMessageNumber: FITMessageType.event.rawValue,
            fields: [
                FITEventFields.timestamp,
                FITEventFields.event,
                FITEventFields.eventType,
            ]
        )
        encoder.writeDefinitionMessage(definition)
        writeEventData(encoder: encoder, timestamp: timestamp, eventType: eventType)
    }

    private func writeEventData(encoder: FITEncoder, timestamp: Date, eventType: UInt8) {
        var msg = FITDataMessage(localMessageType: 1)
        msg.appendUInt32(fitTimestamp(from: timestamp))
        msg.appendUInt8(0)           // event = timer
        msg.appendUInt8(eventType)   // 0 = start, 4 = stop_all
        encoder.writeDataMessage(msg)
    }

    // MARK: - Records

    private func writeRecords(encoder: FITEncoder, workout: WorkoutData) {
        // Define record message (local type 2)
        let definition = FITDefinitionMessage(
            localMessageType: 2,
            globalMessageNumber: FITMessageType.record.rawValue,
            fields: [
                FITRecordFields.timestamp,
                FITRecordFields.positionLat,
                FITRecordFields.positionLong,
                FITRecordFields.altitude,
                FITRecordFields.heartRate,
                FITRecordFields.cadence,
                FITRecordFields.distance,
                FITRecordFields.speed,
                FITRecordFields.power,
            ]
        )
        encoder.writeDefinitionMessage(definition)

        // Collect all timestamps from route + samples
        var timestamps: [Date]
        if !workout.route.isEmpty {
            timestamps = workout.route.map(\.timestamp)
        } else {
            // Use heart rate samples as timeline
            timestamps = workout.heartRateSamples.map(\.timestamp)
        }

        guard !timestamps.isEmpty else { return }

        var cumulativeDistance: Double = 0
        var prevPoint: RoutePoint?

        for timestamp in timestamps {
            let routePoint = findRoutePoint(in: workout.route, at: timestamp)
            let hr = SampleMatcher.findNearest(in: workout.heartRateSamples, to: timestamp, tolerance: 5)
            let cadence = SampleMatcher.findNearest(in: workout.cadenceSamples, to: timestamp, tolerance: 5)
            let speed = SampleMatcher.findNearest(in: workout.speedSamples, to: timestamp, tolerance: 5)
            let power = SampleMatcher.findNearest(in: workout.powerSamples, to: timestamp, tolerance: 5)

            // Calculate cumulative distance
            if let rp = routePoint, let prev = prevPoint {
                cumulativeDistance += haversineDistance(
                    lat1: prev.latitude, lon1: prev.longitude,
                    lat2: rp.latitude, lon2: rp.longitude
                )
            }

            var msg = FITDataMessage(localMessageType: 2)

            // timestamp
            msg.appendUInt32(fitTimestamp(from: timestamp))

            // position_lat (semicircles)
            if let rp = routePoint {
                msg.appendSInt32(fitSemicircles(from: rp.latitude))
            } else {
                msg.appendSInt32(Int32(bitPattern: UInt32(0x7FFFFFFF)))
            }

            // position_long (semicircles)
            if let rp = routePoint {
                msg.appendSInt32(fitSemicircles(from: rp.longitude))
            } else {
                msg.appendSInt32(Int32(bitPattern: UInt32(0x7FFFFFFF)))
            }

            // altitude
            if let rp = routePoint {
                msg.appendUInt16(fitAltitude(from: rp.altitude))
            } else {
                msg.appendUInt16(UInt16(FITBaseType.uint16.invalidValue))
            }

            // heart_rate
            msg.appendUInt8(hr.map { UInt8(min(255, max(0, $0))) } ?? UInt8(FITBaseType.uint8.invalidValue))

            // cadence
            msg.appendUInt8(cadence.map { UInt8(min(255, max(0, $0))) } ?? UInt8(FITBaseType.uint8.invalidValue))

            // distance (cumulative, m * 100)
            msg.appendUInt32(fitDistance(from: cumulativeDistance))

            // speed (m/s * 1000)
            if let spd = speed ?? routePoint.map(\.speed) {
                msg.appendUInt16(fitSpeed(from: max(0, spd)))
            } else {
                msg.appendUInt16(UInt16(FITBaseType.uint16.invalidValue))
            }

            // power
            if let pwr = power {
                msg.appendUInt16(UInt16(min(65534, max(0, pwr))))
            } else {
                msg.appendUInt16(UInt16(FITBaseType.uint16.invalidValue))
            }

            encoder.writeDataMessage(msg)
            prevPoint = routePoint
        }
    }

    // MARK: - Lap

    private func writeLap(encoder: FITEncoder, workout: WorkoutData) {
        let definition = FITDefinitionMessage(
            localMessageType: 3,
            globalMessageNumber: FITMessageType.lap.rawValue,
            fields: [
                FITLapFields.timestamp,
                FITLapFields.startTime,
                FITLapFields.totalElapsedTime,
                FITLapFields.totalTimerTime,
                FITLapFields.totalDistance,
                FITLapFields.totalCalories,
                FITLapFields.avgHeartRate,
                FITLapFields.maxHeartRate,
                FITLapFields.event,
                FITLapFields.eventType,
            ]
        )
        encoder.writeDefinitionMessage(definition)

        let elapsedMs = UInt32(workout.duration * 1000)
        let distanceCm = workout.totalDistance.map { fitDistance(from: $0.converted(to: .meters).value) } ?? 0
        let calories = workout.totalEnergyBurned.map { UInt16($0.converted(to: .kilocalories).value) } ?? 0

        let hrValues = workout.heartRateSamples.map(\.value)
        let avgHR = hrValues.isEmpty ? UInt8(0) : UInt8(hrValues.reduce(0, +) / Double(hrValues.count))
        let maxHR = hrValues.isEmpty ? UInt8(0) : UInt8(hrValues.max() ?? 0)

        var msg = FITDataMessage(localMessageType: 3)
        msg.appendUInt32(fitTimestamp(from: workout.endDate))
        msg.appendUInt32(fitTimestamp(from: workout.startDate))
        msg.appendUInt32(elapsedMs)
        msg.appendUInt32(elapsedMs)
        msg.appendUInt32(distanceCm)
        msg.appendUInt16(calories)
        msg.appendUInt8(avgHR)
        msg.appendUInt8(maxHR)
        msg.appendUInt8(9)  // event = lap
        msg.appendUInt8(1)  // event_type = stop
        encoder.writeDataMessage(msg)
    }

    // MARK: - Session

    private func writeSession(encoder: FITEncoder, workout: WorkoutData) {
        let definition = FITDefinitionMessage(
            localMessageType: 4,
            globalMessageNumber: FITMessageType.session.rawValue,
            fields: [
                FITSessionFields.timestamp,
                FITSessionFields.startTime,
                FITSessionFields.totalElapsedTime,
                FITSessionFields.totalTimerTime,
                FITSessionFields.totalDistance,
                FITSessionFields.totalCalories,
                FITSessionFields.sport,
                FITSessionFields.subSport,
                FITSessionFields.avgHeartRate,
                FITSessionFields.maxHeartRate,
                FITSessionFields.event,
                FITSessionFields.eventType,
            ]
        )
        encoder.writeDefinitionMessage(definition)

        let elapsedMs = UInt32(workout.duration * 1000)
        let distanceCm = workout.totalDistance.map { fitDistance(from: $0.converted(to: .meters).value) } ?? 0
        let calories = workout.totalEnergyBurned.map { UInt16($0.converted(to: .kilocalories).value) } ?? 0
        let (sport, subSport) = WorkoutTypeMapping.fitSport(for: workout.workoutType)

        let hrValues = workout.heartRateSamples.map(\.value)
        let avgHR = hrValues.isEmpty ? UInt8(0) : UInt8(hrValues.reduce(0, +) / Double(hrValues.count))
        let maxHR = hrValues.isEmpty ? UInt8(0) : UInt8(hrValues.max() ?? 0)

        var msg = FITDataMessage(localMessageType: 4)
        msg.appendUInt32(fitTimestamp(from: workout.endDate))
        msg.appendUInt32(fitTimestamp(from: workout.startDate))
        msg.appendUInt32(elapsedMs)
        msg.appendUInt32(elapsedMs)
        msg.appendUInt32(distanceCm)
        msg.appendUInt16(calories)
        msg.appendUInt8(sport)
        msg.appendUInt8(subSport)
        msg.appendUInt8(avgHR)
        msg.appendUInt8(maxHR)
        msg.appendUInt8(26)  // event = session
        msg.appendUInt8(1)   // event_type = stop
        encoder.writeDataMessage(msg)
    }

    // MARK: - Activity

    private func writeActivity(encoder: FITEncoder, workout: WorkoutData) {
        let definition = FITDefinitionMessage(
            localMessageType: 5,
            globalMessageNumber: FITMessageType.activity.rawValue,
            fields: [
                FITActivityFields.timestamp,
                FITActivityFields.totalTimerTime,
                FITActivityFields.numSessions,
                FITActivityFields.type,
                FITActivityFields.event,
                FITActivityFields.eventType,
            ]
        )
        encoder.writeDefinitionMessage(definition)

        var msg = FITDataMessage(localMessageType: 5)
        msg.appendUInt32(fitTimestamp(from: workout.endDate))
        msg.appendUInt32(UInt32(workout.duration * 1000))
        msg.appendUInt16(1)   // num_sessions
        msg.appendUInt8(0)    // type = manual
        msg.appendUInt8(26)   // event = activity
        msg.appendUInt8(1)    // event_type = stop
        encoder.writeDataMessage(msg)
    }

    // MARK: - Helpers

    private func findRoutePoint(in route: [RoutePoint], at timestamp: Date) -> RoutePoint? {
        guard !route.isEmpty else { return nil }

        // Binary search
        var lo = 0
        var hi = route.count - 1

        while lo <= hi {
            let mid = (lo + hi) / 2
            if route[mid].timestamp < timestamp {
                lo = mid + 1
            } else {
                hi = mid - 1
            }
        }

        // Check exact or near match
        if lo < route.count && abs(route[lo].timestamp.timeIntervalSince(timestamp)) < 1 {
            return route[lo]
        }
        if hi >= 0 && abs(route[hi].timestamp.timeIntervalSince(timestamp)) < 1 {
            return route[hi]
        }

        // For route-based iteration, return exact match
        if lo < route.count && route[lo].timestamp == timestamp {
            return route[lo]
        }

        return nil
    }

    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371000.0
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }
}
