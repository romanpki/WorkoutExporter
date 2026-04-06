import SwiftUI
import MapKit

struct RouteMapView: View {
    let route: [RoutePoint]
    var heartRateSamples: [SampleTimeSeries] = []

    var body: some View {
        Map {
            if segments.isEmpty {
                MapPolyline(coordinates: coordinates)
                    .stroke(.blue, lineWidth: 3)
            } else {
                ForEach(segments.indices, id: \.self) { index in
                    let segment = segments[index]
                    MapPolyline(coordinates: segment.coords)
                        .stroke(segment.color, lineWidth: 3)
                }
            }

            if let first = coordinates.first {
                Annotation(String(localized: "map.start"), coordinate: first) {
                    Image(systemName: "flag.fill")
                        .foregroundStyle(.green)
                }
            }

            if let last = coordinates.last, coordinates.count > 1 {
                Annotation(String(localized: "map.finish"), coordinate: last) {
                    Image(systemName: "flag.checkered")
                        .foregroundStyle(.red)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
    }

    private var coordinates: [CLLocationCoordinate2D] {
        route.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }

    // MARK: - Heart rate gradient segments

    private struct MapSegment {
        let coords: [CLLocationCoordinate2D]
        let color: Color
    }

    private var segments: [MapSegment] {
        guard heartRateSamples.count >= 2, route.count >= 2 else { return [] }

        let hrValues = heartRateSamples.map(\.value)
        let minHR = hrValues.min() ?? 60
        let maxHR = hrValues.max() ?? 200
        let range = maxHR - minHR
        guard range > 5 else { return [] } // Not enough variation

        var result: [MapSegment] = []

        for i in 0..<(route.count - 1) {
            let point = route[i]
            let hr = nearestHeartRate(to: point.timestamp)
            let normalized = hr.map { (($0 - minHR) / range).clamped(to: 0...1) }

            let color = normalized.map { hrColor(normalized: $0) } ?? .blue

            let coordA = CLLocationCoordinate2D(latitude: route[i].latitude, longitude: route[i].longitude)
            let coordB = CLLocationCoordinate2D(latitude: route[i + 1].latitude, longitude: route[i + 1].longitude)

            result.append(MapSegment(coords: [coordA, coordB], color: color))
        }

        return result
    }

    private func nearestHeartRate(to date: Date) -> Double? {
        guard !heartRateSamples.isEmpty else { return nil }

        var lo = 0, hi = heartRateSamples.count - 1
        while lo <= hi {
            let mid = (lo + hi) / 2
            if heartRateSamples[mid].timestamp < date { lo = mid + 1 } else { hi = mid - 1 }
        }

        var best: Double?
        var bestDiff = TimeInterval.infinity
        for i in max(0, lo - 1)...min(heartRateSamples.count - 1, lo) {
            let diff = abs(heartRateSamples[i].timestamp.timeIntervalSince(date))
            if diff < bestDiff && diff <= 30 {
                bestDiff = diff
                best = heartRateSamples[i].value
            }
        }
        return best
    }

    /// Maps a 0...1 normalized HR to a color: blue → green → yellow → orange → red
    private func hrColor(normalized: Double) -> Color {
        switch normalized {
        case ..<0.2: .blue
        case ..<0.4: .green
        case ..<0.6: .yellow
        case ..<0.8: .orange
        default: .red
        }
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
