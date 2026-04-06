import Foundation
import SwiftUI

@Observable
final class AppSettings {
    var unitSystem: UnitSystem {
        didSet { UserDefaults.standard.set(unitSystem.rawValue, forKey: "unitSystem") }
    }

    var defaultExportFormat: ExportFormat {
        didSet { UserDefaults.standard.set(defaultExportFormat.rawValue, forKey: "defaultExportFormat") }
    }

    var appearance: AppAppearance {
        didSet { UserDefaults.standard.set(appearance.rawValue, forKey: "appearance") }
    }

    init() {
        let unitRaw = UserDefaults.standard.string(forKey: "unitSystem") ?? UnitSystem.metric.rawValue
        self.unitSystem = UnitSystem(rawValue: unitRaw) ?? .metric

        let formatRaw = UserDefaults.standard.string(forKey: "defaultExportFormat") ?? ExportFormat.gpx.rawValue
        self.defaultExportFormat = ExportFormat(rawValue: formatRaw) ?? .gpx

        let appearanceRaw = UserDefaults.standard.string(forKey: "appearance") ?? AppAppearance.system.rawValue
        self.appearance = AppAppearance(rawValue: appearanceRaw) ?? .system
    }

    var colorScheme: ColorScheme? {
        switch appearance {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum UnitSystem: String, CaseIterable {
    case metric
    case imperial

    var displayName: String {
        switch self {
        case .metric: String(localized: "settings.units.metric")
        case .imperial: String(localized: "settings.units.imperial")
        }
    }
}

enum AppAppearance: String, CaseIterable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: String(localized: "settings.appearance.system")
        case .light: String(localized: "settings.appearance.light")
        case .dark: String(localized: "settings.appearance.dark")
        }
    }
}
