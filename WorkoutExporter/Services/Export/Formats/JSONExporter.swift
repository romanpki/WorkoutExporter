import Foundation

struct JSONExporter: ExportableFormat {
    let format = ExportFormat.json

    func export(workout: WorkoutData) throws -> Data {
        let codable = CodableWorkoutData(from: workout)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(codable)
    }
}
