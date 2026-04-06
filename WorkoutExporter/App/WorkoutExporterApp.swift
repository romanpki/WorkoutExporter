import SwiftUI

@main
struct WorkoutExporterApp: App {
    @State private var healthKitManager = HealthKitManager()
    @State private var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(healthKitManager)
                .environment(appSettings)
                .preferredColorScheme(appSettings.colorScheme)
        }
    }
}
