import Foundation
import HealthKit

@Observable
final class HealthKitManager {
    private(set) var isAuthorized = false
    private(set) var isAvailable = false
    private(set) var authorizationError: String?

    let healthStore = HKHealthStore()

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
            authorizationError = "HealthKit n'est pas disponible sur cet appareil."
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
