import Foundation
import HealthKit

@Observable
final class WorkoutListViewModel {
    var workouts: [HKWorkout] = []
    var isLoading = false
    var errorMessage: String?
    var searchText = ""
    var selectedActivityType: HKWorkoutActivityType?
    var sortOrder: SortOrder = .dateDescending

    enum SortOrder: String, CaseIterable {
        case dateDescending
        case dateAscending
        case durationDescending
        case distanceDescending
        case caloriesDescending

        var displayName: String {
            switch self {
            case .dateDescending: String(localized: "sort.dateDesc")
            case .dateAscending: String(localized: "sort.dateAsc")
            case .durationDescending: String(localized: "sort.duration")
            case .distanceDescending: String(localized: "sort.distance")
            case .caloriesDescending: String(localized: "sort.calories")
            }
        }
    }

    var filteredWorkouts: [HKWorkout] {
        var result = workouts

        if let selectedActivityType {
            result = result.filter { $0.workoutActivityType == selectedActivityType }
        }

        if !searchText.isEmpty {
            result = result.filter { workout in
                let name = WorkoutTypeMapping.name(for: workout.workoutActivityType)
                let source = workout.sourceRevision.source.name
                return name.localizedCaseInsensitiveContains(searchText) ||
                       source.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortOrder {
        case .dateDescending:
            result.sort { $0.startDate > $1.startDate }
        case .dateAscending:
            result.sort { $0.startDate < $1.startDate }
        case .durationDescending:
            result.sort { $0.duration > $1.duration }
        case .distanceDescending:
            result.sort { ($0.totalDistance?.doubleValue(for: .meter()) ?? 0) >
                          ($1.totalDistance?.doubleValue(for: .meter()) ?? 0) }
        case .caloriesDescending:
            result.sort { ($0.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0) >
                          ($1.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0) }
        }

        return result
    }

    var availableActivityTypes: [HKWorkoutActivityType] {
        let types = Set(workouts.map(\.workoutActivityType))
        return types.sorted { WorkoutTypeMapping.name(for: $0) < WorkoutTypeMapping.name(for: $1) }
    }

    private let healthKitManager: HealthKitManager

    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
    }

    func loadWorkouts() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetcher = WorkoutFetcher(healthStore: healthKitManager.healthStore)
            workouts = try await fetcher.fetchWorkouts()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
