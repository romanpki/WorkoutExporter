import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            List {
                StravaConnectView()

                Section(String(localized: "settings.units")) {
                    Picker(String(localized: "settings.units"), selection: $settings.unitSystem) {
                        ForEach(UnitSystem.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(String(localized: "settings.defaultFormat")) {
                    Picker(String(localized: "settings.defaultFormat"), selection: $settings.defaultExportFormat) {
                        ForEach(ExportFormat.allCases) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                }

                Section(String(localized: "settings.appearance")) {
                    Picker(String(localized: "settings.appearance"), selection: $settings.appearance) {
                        ForEach(AppAppearance.allCases, id: \.self) { appearance in
                            Text(appearance.displayName).tag(appearance)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(String(localized: "settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }
                }
            }
        }
    }
}
