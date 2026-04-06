import Foundation
import HealthKit

@Observable
final class HealthKitManager {
    private(set) var isAuthorized = false
    private(set) var isAvailable = false
    private(set) var authorizationError: String?

    let healthStore = HKHealthStore()

    // MARK: - In-memory cache

    private var cachedWorkoutData: [UUID: WorkoutData] = [:]

    func cachedData(for workoutID: UUID) -> WorkoutData? {
        cachedWorkoutData[workoutID]
    }

    func cacheData(_ data: WorkoutData, for workoutID: UUID) {
        cachedWorkoutData[workoutID] = data
    }

    func clearCache() {
        cachedWorkoutData.removeAll()
    }

    private static let readTypes: Set<HKObjectType> = {
        var types: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKQuantityType(.heartRate),
            HKQuantityType(.stepCount),
            HKQuantityType(.runningPower),
            HKQuantityType(.runningSpeed),
            HKQuantityType(.cyclingPower),
            HKQuantityType(.cyclingSpeed),
            HKQuantityType(.cyclingCadence),
            HKQuantityType(.swimmingStrokeCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.distanceCycling),
            HKQuantityType(.distanceSwimming),
        ]
        return types
    }()

    init() {
        isAvailable = HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async {
        guard isAvailable else {
            authorizationError = String(localized: "permission.unavailable")
            return
        }

        do {
            try await healthStore.requestAuthorization(
                toShare: [],
                read: Self.readTypes
            )
            isAuthorized = true
            authorizationError = nil
        } catch {
            authorizationError = error.localizedDescription
            isAuthorized = false
        }
    }
}
