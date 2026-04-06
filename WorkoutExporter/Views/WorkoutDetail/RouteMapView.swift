import SwiftUI
import MapKit

struct RouteMapView: View {
    let route: [RoutePoint]

    var body: some View {
        Map {
            MapPolyline(coordinates: coordinates)
                .stroke(.blue, lineWidth: 3)

            if let first = coordinates.first {
                Annotation("Départ", coordinate: first) {
                    Image(systemName: "flag.fill")
                        .foregroundStyle(.green)
                }
            }

            if let last = coordinates.last, coordinates.count > 1 {
                Annotation("Arrivée", coordinate: last) {
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
}
