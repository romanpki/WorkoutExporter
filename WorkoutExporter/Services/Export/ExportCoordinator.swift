import Foundation
import HealthKit

final class ExportCoordinator {
    private let healthKitManager: HealthKitManager
    private let routeFetcher: RouteFetcher
    private let sampleFetcher: SampleFetcher

    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        self.routeFetcher = RouteFetcher(healthStore: healthKitManager.healthStore)
        self.sampleFetcher = SampleFetcher(healthStore: healthKitManager.healthStore)
    }

    /// Hydrate an HKWorkout with all detailed data (route, samples, splits)
    func hydrateWorkout(_ workout: HKWorkout) async throws -> WorkoutData {
        // Fetch all data concurrently
        async let routeResult = routeFetcher.fetchRoute(for: workout)
        async let hrResult = sampleFetcher.fetchHeartRate(start: workout.startDate, end: workout.endDate)
        async let cadenceResult = sampleFetcher.fetchCadence(start: workout.startDate, end: workout.endDate, workoutType: workout.workoutActivityType)
        async let powerResult = sampleFetcher.fetchPower(start: workout.startDate, end: workout.endDate, workoutType: workout.workoutActivityType)
        async let speedResult = sampleFetcher.fetchSpeed(start: workout.startDate, end: workout.endDate, workoutType: workout.workoutActivityType)

        // Collect results (don't fail the whole export if some data is unavailable)
        let route = (try? await routeResult) ?? []
        let heartRate = (try? await hrResult) ?? []
        let cadence = (try? await cadenceResult) ?? []
        let power = (try? await powerResult) ?? []
        let speed = (try? await speedResult) ?? []

        // Swimming strokes
        var strokes: [SampleTimeSeries] = []
        if workout.workoutActivityType == .swimming {
            strokes = (try? await sampleFetcher.fetchSwimmingStrokes(start: workout.startDate, end: workout.endDate)) ?? []
        }

        // Extract splits from workout events
        let splits = extractSplits(from: workout)

        // Build elevation data
        let elevationAscended = workout.metadata?[HKMetadataKeyElevationAscended] as? HKQuantity
        let elevationDescended = workout.metadata?[HKMetadataKeyElevationDescended] as? HKQuantity

        return WorkoutData(
            id: workout.uuid,
            workoutType: workout.workoutActivityType,
            startDate: workout.startDate,
            endDate: workout.endDate,
            duration: workout.duration,
            totalDistance: workout.totalDistance.map {
                Measurement(value: $0.doubleValue(for: .meter()), unit: UnitLength.meters)
            },
            totalEnergyBurned: workout.totalEnergyBurned.map {
                Measurement(value: $0.doubleValue(for: .kilocalorie()), unit: UnitEnergy.kilocalories)
            },
            sourceAppName: workout.sourceRevision.source.name,
            sourceBundleIdentifier: workout.sourceRevision.source.bundleIdentifier,
            metadata: workout.metadata ?? [:],
            route: route,
            heartRateSamples: heartRate,
            cadenceSamples: cadence,
            powerSamples: power,
            speedSamples: speed,
            strokeSamples: strokes,
            splits: splits,
            elevationAscended: elevationAscended.map {
                Measurement(value: $0.doubleValue(for: .meter()), unit: UnitLength.meters)
            },
            elevationDescended: elevationDescended.map {
                Measurement(value: $0.doubleValue(for: .meter()), unit: UnitLength.meters)
            }
        )
    }

    /// Export a workout in the specified format
    func export(workout: HKWorkout, format: ExportFormat) async throws -> (Data, String) {
        let workoutData = try await hydrateWorkout(workout)

        let exporter: ExportableFormat = switch format {
        case .gpx: GPXExporter()
        case .tcx: TCXExporter()
        case .fit: FITExporter()
        case .csv: CSVExporter()
        case .json: JSONExporter()
        case .xml: XMLExporter()
        }

        let data = try exporter.export(workout: workoutData)
        let fileName = ExportViewModel.fileName(for: workout, format: format)

        return (data, fileName)
    }

    // MARK: - Private

    private func extractSplits(from workout: HKWorkout) -> [WorkoutSplit] {
        guard let events = workout.workoutEvents else { return [] }

        let lapEvents = events.filter { $0.type == .lap || $0.type == .segment }
        guard !lapEvents.isEmpty else { return [] }

        var splits: [WorkoutSplit] = []
        for (index, event) in lapEvents.enumerated() {
            let startDate = event.dateInterval.start
            let endDate = event.dateInterval.end

            splits.append(WorkoutSplit(
                splitNumber: index + 1,
                startDate: startDate,
                endDate: endDate,
                distanceMeters: nil, // Not available from events
                duration: endDate.timeIntervalSince(startDate)
            ))
        }

        return splits
    }
}
