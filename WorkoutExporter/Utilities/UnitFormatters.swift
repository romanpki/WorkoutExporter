import Foundation

enum UnitFormatters {
    static func formatDistance(_ meters: Double) -> String {
        if meters >= 1000 {
            let km = meters / 1000
            return String(format: "%.2f km", km)
        } else {
            return String(format: "%.0f m", meters)
        }
    }

    static func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60

        if hours > 0 {
            return String(format: "%dh %02dmin %02ds", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%dmin %02ds", minutes, secs)
        } else {
            return String(format: "%ds", secs)
        }
    }

    static func formatDurationShort(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }

    static func formatPace(metersPerSecond: Double) -> String {
        guard metersPerSecond > 0 else { return "--" }
        let secondsPerKm = 1000.0 / metersPerSecond
        let minutes = Int(secondsPerKm) / 60
        let seconds = Int(secondsPerKm) % 60
        return String(format: "%d'%02d\"/km", minutes, seconds)
    }

    static func formatCalories(_ kcal: Double) -> String {
        if kcal >= 1000 {
            return String(format: "%.1f kcal", kcal)
        }
        return String(format: "%.0f kcal", kcal)
    }

    static func formatHeartRate(_ bpm: Double) -> String {
        String(format: "%.0f bpm", bpm)
    }
}
