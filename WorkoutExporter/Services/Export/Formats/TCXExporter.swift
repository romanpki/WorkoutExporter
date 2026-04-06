import Foundation
import HealthKit

struct TCXExporter: ExportableFormat {
    let format = ExportFormat.tcx

    func export(workout: WorkoutData) throws -> Data {
        let xml = XMLBuilder()
        xml.xmlDeclaration()

        xml.openTag("TrainingCenterDatabase", attributes: [
            ("xmlns", "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"),
            ("xmlns:ns3", "http://www.garmin.com/xmlschemas/ActivityExtension/v2"),
            ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance"),
            ("xsi:schemaLocation", "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd"),
        ])

        xml.openTag("Activities")

        let sport = WorkoutTypeMapping.tcxSport(for: workout.workoutType)
        xml.openTag("Activity", attributes: [("Sport", sport)])

        xml.element("Id", value: DateFormatters.iso8601Fractional.string(from: workout.startDate))

        // Create laps from splits, or one lap for the whole workout
        let laps = buildLaps(workout: workout)
        for lap in laps {
            writeLap(xml: xml, lap: lap, workout: workout)
        }

        // Creator
        xml.openTag("Creator", attributes: [("xsi:type", "Device_t")])
        xml.element("Name", value: workout.sourceAppName)
        xml.element("UnitId", value: "0")
        xml.element("ProductID", value: "0")
        xml.openTag("Version")
        xml.element("VersionMajor", value: "1")
        xml.element("VersionMinor", value: "0")
        xml.closeTag("Version")
        xml.closeTag("Creator")

        xml.closeTag("Activity")
        xml.closeTag("Activities")
        xml.closeTag("TrainingCenterDatabase")

        guard let data = xml.result.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }

    private struct Lap {
        let startDate: Date
        let endDate: Date
        let distanceMeters: Double?
        let durationSeconds: TimeInterval
        let calories: Double?
    }

    private func buildLaps(workout: WorkoutData) -> [Lap] {
        if workout.splits.isEmpty {
            return [Lap(
                startDate: workout.startDate,
                endDate: workout.endDate,
                distanceMeters: workout.totalDistance?.converted(to: .meters).value,
                durationSeconds: workout.duration,
                calories: workout.totalEnergyBurned?.converted(to: .kilocalories).value
            )]
        }

        return workout.splits.map { split in
            Lap(
                startDate: split.startDate,
                endDate: split.endDate,
                distanceMeters: split.distanceMeters,
                durationSeconds: split.duration,
                calories: nil
            )
        }
    }

    private func writeLap(xml: XMLBuilder, lap: Lap, workout: WorkoutData) {
        xml.openTag("Lap", attributes: [
            ("StartTime", DateFormatters.iso8601Fractional.string(from: lap.startDate))
        ])

        xml.element("TotalTimeSeconds", value: String(format: "%.1f", lap.durationSeconds))

        if let distance = lap.distanceMeters {
            xml.element("DistanceMeters", value: String(format: "%.2f", distance))
        }

        if let calories = lap.calories {
            xml.element("Calories", value: String(format: "%.0f", calories))
        }

        // Heart rate stats for this lap
        let lapHR = workout.heartRateSamples.filter {
            $0.timestamp >= lap.startDate && $0.timestamp <= lap.endDate
        }
        if let avgHR = lapHR.isEmpty ? nil : lapHR.map(\.value).reduce(0, +) / Double(lapHR.count) {
            xml.openTag("AverageHeartRateBpm")
            xml.element("Value", value: String(format: "%.0f", avgHR))
            xml.closeTag("AverageHeartRateBpm")
        }
        if let maxHR = lapHR.map(\.value).max() {
            xml.openTag("MaximumHeartRateBpm")
            xml.element("Value", value: String(format: "%.0f", maxHR))
            xml.closeTag("MaximumHeartRateBpm")
        }

        xml.element("Intensity", value: "Active")
        xml.element("TriggerMethod", value: "Manual")

        // Track
        xml.openTag("Track")

        // Build trackpoints from route or from samples
        let trackpoints = buildTrackpoints(workout: workout, start: lap.startDate, end: lap.endDate)
        var cumulativeDistance: Double = 0.0
        var previousPoint: RoutePoint?

        for tp in trackpoints {
            xml.openTag("Trackpoint")

            xml.element("Time", value: DateFormatters.iso8601Fractional.string(from: tp.timestamp))

            if let point = tp.routePoint {
                xml.openTag("Position")
                xml.element("LatitudeDegrees", value: String(format: "%.7f", point.latitude))
                xml.element("LongitudeDegrees", value: String(format: "%.7f", point.longitude))
                xml.closeTag("Position")

                xml.element("AltitudeMeters", value: String(format: "%.1f", point.altitude))

                // Cumulative distance
                if let prev = previousPoint {
                    cumulativeDistance += haversineDistance(
                        lat1: prev.latitude, lon1: prev.longitude,
                        lat2: point.latitude, lon2: point.longitude
                    )
                }
                xml.element("DistanceMeters", value: String(format: "%.2f", cumulativeDistance))
                previousPoint = point
            }

            if let hr = tp.heartRate {
                xml.openTag("HeartRateBpm")
                xml.element("Value", value: String(format: "%.0f", hr))
                xml.closeTag("HeartRateBpm")
            }

            if let cadence = tp.cadence {
                xml.element("Cadence", value: String(format: "%.0f", cadence))
            }

            // Extensions for speed, power, run cadence
            let hasExtensions = tp.speed != nil || tp.power != nil
            if hasExtensions {
                xml.openTag("Extensions")
                xml.openTag("ns3:TPX")
                if let speed = tp.speed {
                    xml.element("ns3:Speed", value: String(format: "%.2f", speed))
                }
                if let power = tp.power {
                    xml.element("ns3:Watts", value: String(format: "%.0f", power))
                }
                xml.closeTag("ns3:TPX")
                xml.closeTag("Extensions")
            }

            xml.closeTag("Trackpoint")
        }

        xml.closeTag("Track")
        xml.closeTag("Lap")
    }

    private struct Trackpoint {
        let timestamp: Date
        let routePoint: RoutePoint?
        let heartRate: Double?
        let cadence: Double?
        let speed: Double?
        let power: Double?
    }

    private func buildTrackpoints(workout: WorkoutData, start: Date, end: Date) -> [Trackpoint] {
        // Use route points as primary timeline, enriched with samples
        let routePoints = workout.route.filter { $0.timestamp >= start && $0.timestamp <= end }

        if routePoints.isEmpty {
            // No route: use heart rate samples as timeline
            return workout.heartRateSamples
                .filter { $0.timestamp >= start && $0.timestamp <= end }
                .map { sample in
                    Trackpoint(
                        timestamp: sample.timestamp,
                        routePoint: nil,
                        heartRate: sample.value,
                        cadence: SampleMatcher.findNearest(in: workout.cadenceSamples, to: sample.timestamp, tolerance: 5),
                        speed: SampleMatcher.findNearest(in: workout.speedSamples, to: sample.timestamp, tolerance: 5),
                        power: SampleMatcher.findNearest(in: workout.powerSamples, to: sample.timestamp, tolerance: 5)
                    )
                }
        }

        return routePoints.map { point in
            Trackpoint(
                timestamp: point.timestamp,
                routePoint: point,
                heartRate: SampleMatcher.findNearest(in: workout.heartRateSamples, to: point.timestamp, tolerance: 5),
                cadence: SampleMatcher.findNearest(in: workout.cadenceSamples, to: point.timestamp, tolerance: 5),
                speed: SampleMatcher.findNearest(in: workout.speedSamples, to: point.timestamp, tolerance: 5),
                power: SampleMatcher.findNearest(in: workout.powerSamples, to: point.timestamp, tolerance: 5)
            )
        }
    }

    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371000.0 // Earth radius in meters
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }
}
