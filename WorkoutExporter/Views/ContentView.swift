import SwiftUI

struct ContentView: View {
    @Environment(HealthKitManager.self) private var healthKitManager

    var body: some View {
        Group {
            if healthKitManager.isAuthorized {
                WorkoutListView()
            } else {
                HealthKitPermissionView()
            }
        }
    }
}
