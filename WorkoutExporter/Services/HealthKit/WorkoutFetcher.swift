import Foundation
import HealthKit

struct WorkoutFetcher {
    let healthStore: HKHealthStore

    func fetchWorkouts(
        activityType: HKWorkoutActivityType? = nil,
        startDateFrom: Date? = nil,
        startDateTo: Date? = nil,
        limit: Int? = nil
    ) async throws -> [HKWorkout] {
        var predicates: [NSPredicate] = []

        if let activityType {
            predicates.append(
                HKQuery.predicateForWorkouts(with: activityType)
            )
        }

        if let startDateFrom {
            predicates.append(
                HKQuery.predicateForSamples(
                    withStart: startDateFrom,
                    end: startDateTo ?? Date(),
                    options: .strictStartDate
                )
            )
        }

        let compound = predicates.isEmpty
            ? nil
            : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let descriptor = HKSampleQueryDescriptor(
            predicates: [.workout(compound)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)],
            limit: limit
        )

        let results = try await descriptor.result(for: healthStore)
        return results
    }

    func fetchSources() async throws -> [String] {
        let workouts = try await fetchWorkouts(limit: 200)
        let sources = Set(workouts.map { $0.sourceRevision.source.name })
        return sources.sorted()
    }
}
