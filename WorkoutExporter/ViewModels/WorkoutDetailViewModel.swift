import Foundation
import HealthKit

@Observable
final class WorkoutDetailViewModel {
    let workout: HKWorkout
    var workoutData: WorkoutData?
    var isLoading = false
    var errorMessage: String?

    private let healthKitManager: HealthKitManager

    init(workout: HKWorkout, healthKitManager: HealthKitManager) {
        self.workout = workout
        self.healthKitManager = healthKitManager
    }

    var workoutName: String {
        WorkoutTypeMapping.name(for: workout.workoutActivityType)
    }

    var workoutIcon: String {
        WorkoutTypeMapping.sfSymbol(for: workout.workoutActivityType)
    }

    var formattedDate: String {
        DateFormatters.workoutDisplay.string(from: workout.startDate)
    }

    var formattedDuration: String {
        UnitFormatters.formatDuration(workout.duration)
    }

    var formattedDistance: String? {
        guard let distance = workout.totalDistance else { return nil }
        return UnitFormatters.formatDistance(distance.doubleValue(for: .meter()))
    }

    var formattedCalories: String? {
        guard let energy = workout.totalEnergyBurned else { return nil }
        return UnitFormatters.formatCalories(energy.doubleValue(for: .kilocalorie()))
    }

    var sourceName: String {
        workout.sourceRevision.source.name
    }

    func loadDetailData() async {
        guard workoutData == nil else { return }

        isLoading = true
        errorMessage = nil

        do {
            let coordinator = ExportCoordinator(healthKitManager: healthKitManager)
            workoutData = try await coordinator.hydrateWorkout(workout)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    var averageHeartRate: Double? {
        guard let samples = workoutData?.heartRateSamples, !samples.isEmpty else { return nil }
        return samples.map(\.value).reduce(0, +) / Double(samples.count)
    }

    var maxHeartRate: Double? {
        workoutData?.heartRateSamples.map(\.value).max()
    }

    var hasRoute: Bool {
        workoutData?.route.isEmpty == false
    }
}
