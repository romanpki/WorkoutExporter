import Foundation
import HealthKit

struct WorkoutData: Identifiable {
    let id: UUID
    let workoutType: HKWorkoutActivityType
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let totalDistance: Measurement<UnitLength>?
    let totalEnergyBurned: Measurement<UnitEnergy>?
    let sourceAppName: String
    let sourceBundleIdentifier: String
    let metadata: [String: Any]

    var route: [RoutePoint]
    var heartRateSamples: [SampleTimeSeries]
    var cadenceSamples: [SampleTimeSeries]
    var powerSamples: [SampleTimeSeries]
    var speedSamples: [SampleTimeSeries]
    var strokeSamples: [SampleTimeSeries]
    var splits: [WorkoutSplit]
    var elevationAscended: Measurement<UnitLength>?
    var elevationDescended: Measurement<UnitLength>?
}

// MARK: - Codable wrapper for JSON export

struct CodableWorkoutData: Codable {
    let id: String
    let workoutType: String
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let totalDistanceMeters: Double?
    let totalEnergyBurnedKcal: Double?
    let sourceAppName: String
    let sourceBundleIdentifier: String
    let route: [RoutePoint]
    let heartRateSamples: [CodableSample]
    let cadenceSamples: [CodableSample]
    let powerSamples: [CodableSample]
    let speedSamples: [CodableSample]
    let strokeSamples: [CodableSample]
    let splits: [WorkoutSplit]
    let elevationAscendedMeters: Double?
    let elevationDescendedMeters: Double?

    init(from workout: WorkoutData) {
        self.id = workout.id.uuidString
        self.workoutType = WorkoutTypeMapping.name(for: workout.workoutType)
        self.startDate = workout.startDate
        self.endDate = workout.endDate
        self.duration = workout.duration
        self.totalDistanceMeters = workout.totalDistance?.converted(to: .meters).value
        self.totalEnergyBurnedKcal = workout.totalEnergyBurned?.converted(to: .kilocalories).value
        self.sourceAppName = workout.sourceAppName
        self.sourceBundleIdentifier = workout.sourceBundleIdentifier
        self.route = workout.route
        self.heartRateSamples = workout.heartRateSamples.map { CodableSample(timestamp: $0.timestamp, value: $0.value, unit: "bpm") }
        self.cadenceSamples = workout.cadenceSamples.map { CodableSample(timestamp: $0.timestamp, value: $0.value, unit: "rpm") }
        self.powerSamples = workout.powerSamples.map { CodableSample(timestamp: $0.timestamp, value: $0.value, unit: "W") }
        self.speedSamples = workout.speedSamples.map { CodableSample(timestamp: $0.timestamp, value: $0.value, unit: "m/s") }
        self.strokeSamples = workout.strokeSamples.map { CodableSample(timestamp: $0.timestamp, value: $0.value, unit: "count") }
        self.splits = workout.splits
        self.elevationAscendedMeters = workout.elevationAscended?.converted(to: .meters).value
        self.elevationDescendedMeters = workout.elevationDescended?.converted(to: .meters).value
    }
}

struct CodableSample: Codable {
    let timestamp: Date
    let value: Double
    let unit: String
}
