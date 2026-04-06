import Foundation
import HealthKit

@Observable
final class ExportViewModel {
    var selectedFormat: ExportFormat
    var isExporting = false
    var exportedFileURL: URL?
    var errorMessage: String?
    var showShareSheet = false

    private let healthKitManager: HealthKitManager

    init(healthKitManager: HealthKitManager, defaultFormat: ExportFormat = .gpx) {
        self.healthKitManager = healthKitManager
        self.selectedFormat = defaultFormat
    }

    func exportWorkout(_ workout: HKWorkout, format: ExportFormat) async {
        isExporting = true
        errorMessage = nil
        exportedFileURL = nil

        do {
            let coordinator = ExportCoordinator(healthKitManager: healthKitManager)
            let (data, fileName) = try await coordinator.export(workout: workout, format: format)

            // Write to temp directory
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName)
            try data.write(to: fileURL)

            exportedFileURL = fileURL
            showShareSheet = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isExporting = false
    }

    func saveToFiles(_ workout: HKWorkout, format: ExportFormat) async {
        await exportWorkout(workout, format: format)
    }

    static func fileName(for workout: HKWorkout, format: ExportFormat) -> String {
        let typeName = WorkoutTypeMapping.name(for: workout.workoutActivityType)
            .replacingOccurrences(of: " ", with: "_")
        let date = DateFormatters.fileName.string(from: workout.startDate)
        return "\(typeName)_\(date).\(format.fileExtension)"
    }
}
