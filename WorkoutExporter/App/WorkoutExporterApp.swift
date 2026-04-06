import SwiftUI

@main
struct WorkoutExporterApp: App {
    @State private var healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(healthKitManager)
        }
    }
}
