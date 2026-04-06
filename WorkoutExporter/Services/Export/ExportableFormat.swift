import Foundation

protocol ExportableFormat {
    var format: ExportFormat { get }
    func export(workout: WorkoutData) throws -> Data
}
