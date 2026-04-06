import Foundation

struct WorkoutSplit: Codable {
    let splitNumber: Int
    let startDate: Date
    let endDate: Date
    let distanceMeters: Double?
    let duration: TimeInterval
}
