import SwiftUI

struct ContentView: View {
    @Environment(HealthKitManager.self) private var healthKitManager

    var body: some View {
        Group {
            if healthKitManager.isAuthorized {
                TabView {
                    WorkoutListView()
                        .tabItem {
                            Label(String(localized: "list.title"), systemImage: "figure.run")
                        }

                    StatsView()
                        .tabItem {
                            Label(String(localized: "stats.title"), systemImage: "chart.bar")
                        }
                }
            } else {
                HealthKitPermissionView()
            }
        }
    }
}
