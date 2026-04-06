import Foundation
import HealthKit

struct GPXExporter: ExportableFormat {
    let format = ExportFormat.gpx

    func export(workout: WorkoutData) throws -> Data {
        let xml = XMLBuilder()
        xml.xmlDeclaration()

        xml.openTag("gpx", attributes: [
            ("version", "1.1"),
            ("creator", "WorkoutExporter"),
            ("xmlns", "http://www.topografix.com/GPX/1/1"),
            ("xmlns:gpxtpx", "http://www.garmin.com/xmlschemas/TrackPointExtension/v2"),
            ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance"),
            ("xsi:schemaLocation", "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"),
        ])

        // Metadata
        xml.openTag("metadata")
        xml.element("name", value: WorkoutTypeMapping.name(for: workout.workoutType))
        xml.element("time", value: DateFormatters.iso8601Fractional.string(from: workout.startDate))
        xml.closeTag("metadata")

        // Track
        xml.openTag("trk")
        xml.element("name", value: "\(WorkoutTypeMapping.name(for: workout.workoutType)) - \(DateFormatters.workoutDisplay.string(from: workout.startDate))")
        xml.element("type", value: gpxType(for: workout.workoutType))

        xml.openTag("trkseg")

        if workout.route.isEmpty {
            // No route — export just heart rate samples as waypoints with time only
            // (Not standard GPX, but some tools accept it)
        } else {
            for point in workout.route {
                let hr = SampleMatcher.findNearest(in: workout.heartRateSamples, to: point.timestamp, tolerance: 5)
                let cadence = SampleMatcher.findNearest(in: workout.cadenceSamples, to: point.timestamp, tolerance: 5)
                let power = SampleMatcher.findNearest(in: workout.powerSamples, to: point.timestamp, tolerance: 5)

                xml.openTag("trkpt", attributes: [
                    ("lat", String(format: "%.7f", point.latitude)),
                    ("lon", String(format: "%.7f", point.longitude)),
                ])

                xml.element("ele", value: String(format: "%.1f", point.altitude))
                xml.element("time", value: DateFormatters.iso8601Fractional.string(from: point.timestamp))

                // Extensions (Garmin TrackPointExtension)
                let hasExtensions = hr != nil || cadence != nil || power != nil
                if hasExtensions {
                    xml.openTag("extensions")
                    xml.openTag("gpxtpx:TrackPointExtension")

                    if let hr {
                        xml.element("gpxtpx:hr", value: String(format: "%.0f", hr))
                    }
                    if let cadence {
                        xml.element("gpxtpx:cad", value: String(format: "%.0f", cadence))
                    }
                    // Power is not standard in gpxtpx but widely supported
                    if let power {
                        xml.element("gpxtpx:power", value: String(format: "%.0f", power))
                    }

                    xml.closeTag("gpxtpx:TrackPointExtension")
                    xml.closeTag("extensions")
                }

                xml.closeTag("trkpt")
            }
        }

        xml.closeTag("trkseg")
        xml.closeTag("trk")
        xml.closeTag("gpx")

        guard let data = xml.result.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }

    private func gpxType(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: "running"
        case .cycling: "cycling"
        case .walking: "walking"
        case .hiking: "hiking"
        case .swimming: "swimming"
        default: "other"
        }
    }
}

// MARK: - Sample matching utility

enum SampleMatcher {
    /// Binary search to find the nearest sample value within a given tolerance (seconds)
    static func findNearest(in samples: [SampleTimeSeries], to target: Date, tolerance: TimeInterval) -> Double? {
        guard !samples.isEmpty else { return nil }

        // Binary search for the closest timestamp
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

        // Check candidates around the insertion point
        var bestValue: Double?
        var bestDiff = TimeInterval.infinity

        let candidates = [hi, lo].filter { $0 >= 0 && $0 < samples.count }
        for i in candidates {
            let diff = abs(samples[i].timestamp.timeIntervalSince(target))
            if diff < bestDiff && diff <= tolerance {
                bestDiff = diff
                bestValue = samples[i].value
            }
        }

        return bestValue
    }
}
