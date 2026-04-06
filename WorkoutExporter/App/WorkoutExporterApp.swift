import SwiftUI

@main
struct WorkoutExporterApp: App {
    @State private var healthKitManager = HealthKitManager()
    @State private var appSettings = AppSettings()
    @State private var stravaAuthManager = StravaAuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(healthKitManager)
                .environment(appSettings)
                .environment(stravaAuthManager)
                .preferredColorScheme(appSettings.colorScheme)
        }
    }
}
