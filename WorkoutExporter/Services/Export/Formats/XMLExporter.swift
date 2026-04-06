import Foundation
import HealthKit

struct XMLExporter: ExportableFormat {
    let format = ExportFormat.xml

    func export(workout: WorkoutData) throws -> Data {
        let xml = XMLBuilder()
        xml.xmlDeclaration()

        xml.openTag("HealthData", attributes: [("locale", "fr_FR")])

        // Workout element
        var workoutAttrs: [(String, String)] = [
            ("workoutActivityType", "HKWorkoutActivityType\(hkActivityTypeName(workout.workoutType))"),
            ("duration", String(format: "%.2f", workout.duration / 60)),
            ("durationUnit", "min"),
            ("sourceName", workout.sourceAppName),
            ("sourceVersion", ""),
            ("startDate", DateFormatters.appleHealthExport.string(from: workout.startDate)),
            ("endDate", DateFormatters.appleHealthExport.string(from: workout.endDate)),
        ]

        if let distance = workout.totalDistance {
            let km = distance.converted(to: .kilometers).value
            workoutAttrs.append(("totalDistance", String(format: "%.4f", km)))
            workoutAttrs.append(("totalDistanceUnit", "km"))
        }

        if let energy = workout.totalEnergyBurned {
            let kcal = energy.converted(to: .kilocalories).value
            workoutAttrs.append(("totalEnergyBurned", String(format: "%.4f", kcal)))
            workoutAttrs.append(("totalEnergyBurnedUnit", "kcal"))
        }

        xml.openTag("Workout", attributes: workoutAttrs)

        // Route data
        if !workout.route.isEmpty {
            xml.openTag("WorkoutRoute", attributes: [
                ("sourceName", workout.sourceAppName),
                ("startDate", DateFormatters.appleHealthExport.string(from: workout.startDate)),
                ("endDate", DateFormatters.appleHealthExport.string(from: workout.endDate)),
            ])

            for point in workout.route {
                xml.selfClosingElement("Location", attributes: [
                    ("date", DateFormatters.appleHealthExport.string(from: point.timestamp)),
                    ("latitude", String(format: "%.7f", point.latitude)),
                    ("longitude", String(format: "%.7f", point.longitude)),
                    ("altitude", String(format: "%.2f", point.altitude)),
                    ("horizontalAccuracy", String(format: "%.2f", point.horizontalAccuracy)),
                    ("verticalAccuracy", String(format: "%.2f", point.verticalAccuracy)),
                    ("speed", String(format: "%.2f", point.speed)),
                    ("course", String(format: "%.2f", point.course)),
                ])
            }

            xml.closeTag("WorkoutRoute")
        }

        // Heart rate records
        if !workout.heartRateSamples.isEmpty {
            for sample in workout.heartRateSamples {
                xml.selfClosingElement("Record", attributes: [
                    ("type", "HKQuantityTypeIdentifierHeartRate"),
                    ("sourceName", workout.sourceAppName),
                    ("unit", "count/min"),
                    ("startDate", DateFormatters.appleHealthExport.string(from: sample.timestamp)),
                    ("value", String(format: "%.0f", sample.value)),
                ])
            }
        }

        // Cadence records
        for sample in workout.cadenceSamples {
            xml.selfClosingElement("Record", attributes: [
                ("type", "HKQuantityTypeIdentifierStepCount"),
                ("sourceName", workout.sourceAppName),
                ("unit", "count"),
                ("startDate", DateFormatters.appleHealthExport.string(from: sample.timestamp)),
                ("value", String(format: "%.0f", sample.value)),
            ])
        }

        // Power records
        for sample in workout.powerSamples {
            xml.selfClosingElement("Record", attributes: [
                ("type", "HKQuantityTypeIdentifierRunningPower"),
                ("sourceName", workout.sourceAppName),
                ("unit", "W"),
                ("startDate", DateFormatters.appleHealthExport.string(from: sample.timestamp)),
                ("value", String(format: "%.0f", sample.value)),
            ])
        }

        // Speed records
        for sample in workout.speedSamples {
            xml.selfClosingElement("Record", attributes: [
                ("type", "HKQuantityTypeIdentifierRunningSpeed"),
                ("sourceName", workout.sourceAppName),
                ("unit", "m/s"),
                ("startDate", DateFormatters.appleHealthExport.string(from: sample.timestamp)),
                ("value", String(format: "%.2f", sample.value)),
            ])
        }

        // Splits
        for split in workout.splits {
            xml.selfClosingElement("WorkoutEvent", attributes: [
                ("type", "HKWorkoutEventTypeLap"),
                ("startDate", DateFormatters.appleHealthExport.string(from: split.startDate)),
                ("endDate", DateFormatters.appleHealthExport.string(from: split.endDate)),
                ("duration", String(format: "%.2f", split.duration)),
            ])
        }

        xml.closeTag("Workout")
        xml.closeTag("HealthData")

        guard let data = xml.result.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }

    private func hkActivityTypeName(_ type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: "Running"
        case .cycling: "Cycling"
        case .swimming: "Swimming"
        case .walking: "Walking"
        case .hiking: "Hiking"
        case .yoga: "Yoga"
        case .functionalStrengthTraining: "FunctionalStrengthTraining"
        case .traditionalStrengthTraining: "TraditionalStrengthTraining"
        case .crossTraining: "CrossTraining"
        case .elliptical: "Elliptical"
        case .rowing: "Rowing"
        case .highIntensityIntervalTraining: "HighIntensityIntervalTraining"
        case .coreTraining: "CoreTraining"
        case .dance: "Dance"
        case .pilates: "Pilates"
        case .soccer: "Soccer"
        case .basketball: "Basketball"
        case .tennis: "Tennis"
        case .golf: "Golf"
        case .surfingSports: "SurfingSports"
        case .snowboarding: "Snowboarding"
        case .downhillSkiing: "DownhillSkiing"
        case .crossCountrySkiing: "CrossCountrySkiing"
        case .climbing: "Climbing"
        case .boxing: "Boxing"
        case .martialArts: "MartialArts"
        case .stairClimbing: "StairClimbing"
        case .jumpRope: "JumpRope"
        case .mixedCardio: "MixedCardio"
        case .mindAndBody: "MindAndBody"
        case .swimBikeRun: "SwimBikeRun"
        default: "Other"
        }
    }
}
