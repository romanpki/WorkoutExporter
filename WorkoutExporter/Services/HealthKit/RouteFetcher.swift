import Foundation
import HealthKit
import CoreLocation

struct RouteFetcher {
    let healthStore: HKHealthStore

    func fetchRoute(for workout: HKWorkout) async throws -> [RoutePoint] {
        let routes = try await fetchWorkoutRoutes(for: workout)

        var allPoints: [RoutePoint] = []
        for route in routes {
            let locations = try await fetchLocations(for: route)
            let points = locations.map { RoutePoint(from: $0) }
            allPoints.append(contentsOf: points)
        }

        // Sort by timestamp to ensure correct order
        allPoints.sort { $0.timestamp < $1.timestamp }
        return allPoints
    }

    private func fetchWorkoutRoutes(for workout: HKWorkout) async throws -> [HKWorkoutRoute] {
        let predicate = HKQuery.predicateForObjects(from: workout)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.workoutRoute(predicate)],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )
        return try await descriptor.result(for: healthStore)
    }

    private func fetchLocations(for route: HKWorkoutRoute) async throws -> [CLLocation] {
        try await withCheckedThrowingContinuation { continuation in
            var allLocations: [CLLocation] = []
            var didResume = false

            let query = HKWorkoutRouteQuery(route: route) { _, locations, done, error in
                if let error, !didResume {
                    didResume = true
                    continuation.resume(throwing: error)
                    return
                }

                if let locations {
                    allLocations.append(contentsOf: locations)
                }

                if done, !didResume {
                    didResume = true
                    continuation.resume(returning: allLocations)
                }
            }

            healthStore.execute(query)
        }
    }
}
