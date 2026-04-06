import Foundation

struct CSVExporter: ExportableFormat {
    let format = ExportFormat.csv

    func export(workout: WorkoutData) throws -> Data {
        var csv = ""

        // Header comment with workout summary
        csv += "# Workout: \(workout.workoutType.rawValue)\n"
        csv += "# Start: \(DateFormatters.iso8601.string(from: workout.startDate))\n"
        csv += "# End: \(DateFormatters.iso8601.string(from: workout.endDate))\n"
        csv += "# Duration: \(workout.duration) seconds\n"
        if let distance = workout.totalDistance {
            csv += "# Distance: \(distance.converted(to: .meters).value) meters\n"
        }
        if let energy = workout.totalEnergyBurned {
            csv += "# Energy: \(energy.converted(to: .kilocalories).value) kcal\n"
        }
        csv += "# Source: \(workout.sourceAppName)\n"
        csv += "#\n"

        // Merge all time-series data by timestamp
        let allTimestamps = collectAllTimestamps(workout: workout)

        if allTimestamps.isEmpty {
            // Summary-only export
            csv += "field,value\n"
            csv += "workout_type,\(WorkoutTypeMapping.name(for: workout.workoutType))\n"
            csv += "start_date,\(DateFormatters.csvTimestamp.string(from: workout.startDate))\n"
            csv += "end_date,\(DateFormatters.csvTimestamp.string(from: workout.endDate))\n"
            csv += "duration_seconds,\(String(format: "%.1f", workout.duration))\n"
            if let d = workout.totalDistance {
                csv += "distance_meters,\(String(format: "%.2f", d.converted(to: .meters).value))\n"
            }
            if let e = workout.totalEnergyBurned {
                csv += "energy_kcal,\(String(format: "%.1f", e.converted(to: .kilocalories).value))\n"
            }
        } else {
            // Time-series export
            csv += "timestamp,latitude,longitude,altitude_m,heart_rate_bpm,cadence_rpm,power_w,speed_m_s\n"

            for timestamp in allTimestamps {
                let routePoint = findNearest(in: workout.route.map { ($0.timestamp, $0) }, to: timestamp, tolerance: 5)
                let hr = findNearestValue(in: workout.heartRateSamples, to: timestamp, tolerance: 5)
                let cadence = findNearestValue(in: workout.cadenceSamples, to: timestamp, tolerance: 5)
                let power = findNearestValue(in: workout.powerSamples, to: timestamp, tolerance: 5)
                let speed = findNearestValue(in: workout.speedSamples, to: timestamp, tolerance: 5)

                let ts = DateFormatters.csvTimestamp.string(from: timestamp)
                let lat = routePoint.map { String(format: "%.7f", $0.latitude) } ?? ""
                let lon = routePoint.map { String(format: "%.7f", $0.longitude) } ?? ""
                let alt = routePoint.map { String(format: "%.1f", $0.altitude) } ?? ""
                let hrStr = hr.map { String(format: "%.0f", $0) } ?? ""
                let cadStr = cadence.map { String(format: "%.0f", $0) } ?? ""
                let powStr = power.map { String(format: "%.0f", $0) } ?? ""
                let spdStr = speed.map { String(format: "%.2f", $0) } ?? ""

                csv += "\(ts),\(lat),\(lon),\(alt),\(hrStr),\(cadStr),\(powStr),\(spdStr)\n"
            }
        }

        guard let data = csv.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }

    private func collectAllTimestamps(workout: WorkoutData) -> [Date] {
        var timestamps = Set<Date>()
        workout.route.forEach { timestamps.insert($0.timestamp) }
        workout.heartRateSamples.forEach { timestamps.insert($0.timestamp) }
        workout.cadenceSamples.forEach { timestamps.insert($0.timestamp) }
        workout.powerSamples.forEach { timestamps.insert($0.timestamp) }
        workout.speedSamples.forEach { timestamps.insert($0.timestamp) }
        return timestamps.sorted()
    }

    private func findNearest<T>(in items: [(Date, T)], to target: Date, tolerance: TimeInterval) -> T? {
        guard !items.isEmpty else { return nil }
        var bestItem: T?
        var bestDiff = TimeInterval.infinity
        for (date, item) in items {
            let diff = abs(date.timeIntervalSince(target))
            if diff < bestDiff && diff <= tolerance {
                bestDiff = diff
                bestItem = item
            }
        }
        return bestItem
    }

    private func findNearestValue(in samples: [SampleTimeSeries], to target: Date, tolerance: TimeInterval) -> Double? {
        guard !samples.isEmpty else { return nil }

        var lo = 0
        var hi = samples.count - 1

        while lo <= hi {
            let mid = (lo + hi) / 2
            if samples[mid].timestamp < target {
                lo = mid + 1
            } else {
                hi = mid - 1
            }
        }

        var bestValue: Double?
        var bestDiff = TimeInterval.infinity

        for i in max(0, lo - 1)...min(samples.count - 1, lo) {
            let diff = abs(samples[i].timestamp.timeIntervalSince(target))
            if diff < bestDiff && diff <= tolerance {
                bestDiff = diff
                bestValue = samples[i].value
            }
        }

        return bestValue
    }
}

enum ExportError: LocalizedError {
    case encodingFailed
    case noData

    var errorDescription: String? {
        switch self {
        case .encodingFailed: String(localized: "export.error.encoding")
        case .noData: String(localized: "export.error.noData")
        }
    }
}
