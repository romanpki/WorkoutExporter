import SwiftUI
import HealthKit

struct WorkoutDetailView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    @State private var viewModel: WorkoutDetailViewModel?
    @State private var exportViewModel: ExportViewModel?
    @State private var showExportPicker = false
    let workout: HKWorkout

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                statsSection

                if let vm = viewModel {
                    if vm.isLoading {
                        ProgressView("Chargement des données détaillées...")
                            .padding()
                    }

                    if let data = vm.workoutData, !data.route.isEmpty {
                        RouteMapView(route: data.route)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }

                    if let data = vm.workoutData, !data.heartRateSamples.isEmpty {
                        HeartRateChartView(samples: data.heartRateSamples)
                            .frame(height: 200)
                            .padding(.horizontal)
                    }

                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding()
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(WorkoutTypeMapping.name(for: workout.workoutActivityType))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showExportPicker = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showExportPicker) {
            if let exportViewModel {
                ExportFormatPickerView(
                    viewModel: exportViewModel,
                    workout: workout
                )
            }
        }
        .sheet(isPresented: Binding(
            get: { exportViewModel?.showShareSheet ?? false },
            set: { exportViewModel?.showShareSheet = $0 }
        )) {
            if let url = exportViewModel?.exportedFileURL {
                ShareSheetView(items: [url])
            }
        }
        .task {
            if viewModel == nil {
                viewModel = WorkoutDetailViewModel(workout: workout, healthKitManager: healthKitManager)
            }
            if exportViewModel == nil {
                exportViewModel = ExportViewModel(healthKitManager: healthKitManager)
            }
            await viewModel?.loadDetailData()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: WorkoutTypeMapping.sfSymbol(for: workout.workoutActivityType))
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text(WorkoutTypeMapping.name(for: workout.workoutActivityType))
                .font(.title2.bold())

            Text(DateFormatters.workoutDisplay.string(from: workout.startDate))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Source : \(workout.sourceRevision.source.name)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }

    private var statsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(title: "Durée", value: UnitFormatters.formatDuration(workout.duration), icon: "clock")

            if let distance = workout.totalDistance {
                StatCard(title: "Distance",
                         value: UnitFormatters.formatDistance(distance.doubleValue(for: .meter())),
                         icon: "ruler")
            }

            if let energy = workout.totalEnergyBurned {
                StatCard(title: "Calories",
                         value: UnitFormatters.formatCalories(energy.doubleValue(for: .kilocalorie())),
                         icon: "flame")
            }

            if let avgHR = viewModel?.averageHeartRate {
                StatCard(title: "FC moy.",
                         value: UnitFormatters.formatHeartRate(avgHR),
                         icon: "heart")
            }

            if let maxHR = viewModel?.maxHeartRate {
                StatCard(title: "FC max",
                         value: UnitFormatters.formatHeartRate(maxHR),
                         icon: "heart.fill")
            }

            if let data = viewModel?.workoutData, !data.route.isEmpty {
                StatCard(title: "Points GPS",
                         value: "\(data.route.count)",
                         icon: "location")
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - UIKit Share Sheet wrapper

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
