import Foundation
import HealthKit

struct SampleFetcher {
    let healthStore: HKHealthStore

    func fetchHeartRate(start: Date, end: Date) async throws -> [SampleTimeSeries] {
        try await fetchSamples(
            type: HKQuantityType(.heartRate),
            start: start, end: end,
            unit: HKUnit.count().unitDivided(by: .minute())
        )
    }

    func fetchCadence(start: Date, end: Date, workoutType: HKWorkoutActivityType) async throws -> [SampleTimeSeries] {
        let type: HKQuantityType
        let unit: HKUnit

        switch workoutType {
        case .cycling:
            type = HKQuantityType(.cyclingCadence)
            unit = HKUnit.count().unitDivided(by: .minute())
        default:
            // For running/walking, derive cadence from step count
            type = HKQuantityType(.stepCount)
            unit = HKUnit.count()
        }

        return try await fetchSamples(type: type, start: start, end: end, unit: unit)
    }

    func fetchPower(start: Date, end: Date, workoutType: HKWorkoutActivityType) async throws -> [SampleTimeSeries] {
        let type: HKQuantityType = switch workoutType {
        case .cycling: HKQuantityType(.cyclingPower)
        default: HKQuantityType(.runningPower)
        }

        return try await fetchSamples(type: type, start: start, end: end, unit: .watt())
    }

    func fetchSpeed(start: Date, end: Date, workoutType: HKWorkoutActivityType) async throws -> [SampleTimeSeries] {
        let type: HKQuantityType = switch workoutType {
        case .cycling: HKQuantityType(.cyclingSpeed)
        default: HKQuantityType(.runningSpeed)
        }

        return try await fetchSamples(
            type: type, start: start, end: end,
            unit: HKUnit.meter().unitDivided(by: .second())
        )
    }

    func fetchSwimmingStrokes(start: Date, end: Date) async throws -> [SampleTimeSeries] {
        try await fetchSamples(
            type: HKQuantityType(.swimmingStrokeCount),
            start: start, end: end,
            unit: .count()
        )
    }

    private func fetchSamples(
        type: HKQuantityType,
        start: Date,
        end: Date,
        unit: HKUnit
    ) async throws -> [SampleTimeSeries] {
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: type, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )

        let samples = try await descriptor.result(for: healthStore)
        return samples.map { sample in
            SampleTimeSeries(
                timestamp: sample.startDate,
                value: sample.quantity.doubleValue(for: unit),
                unit: unit
            )
        }
    }
}
