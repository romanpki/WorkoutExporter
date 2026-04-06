import SwiftUI
import HealthKit

struct WorkoutDetailView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    @Environment(AppSettings.self) private var appSettings
    @Environment(StravaAuthManager.self) private var stravaAuth
    @State private var viewModel: WorkoutDetailViewModel?
    @State private var exportViewModel: ExportViewModel?
    @State private var stravaUploader: StravaUploader?
    @State private var showExportPicker = false
    let workout: HKWorkout

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                statsSection

                if stravaAuth.isConnected {
                    stravaSection
                }

                if let vm = viewModel {
                    if vm.isLoading {
                        ProgressView(String(localized: "detail.loading"))
                            .padding()
                    }

                    if let data = vm.workoutData, !data.route.isEmpty {
                        RouteMapView(route: data.route, heartRateSamples: data.heartRateSamples)
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
                        VStack(spacing: 8) {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                            Button(String(localized: "list.retry")) {
                                Task { await vm.loadDetailData() }
                            }
                            .font(.caption.bold())
                        }
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
                exportViewModel = ExportViewModel(healthKitManager: healthKitManager, defaultFormat: appSettings.defaultExportFormat)
            }
            if stravaUploader == nil {
                stravaUploader = StravaUploader(authManager: stravaAuth, healthKitManager: healthKitManager)
            }
            await viewModel?.loadDetailData()
        }
    }

    // MARK: - Strava Upload Section

    private var stravaSection: some View {
        VStack(spacing: 8) {
            if let uploader = stravaUploader {
                if uploader.isUploading {
                    HStack(spacing: 12) {
                        ProgressView()
                        if let progress = uploader.uploadProgress {
                            Text(progress)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                } else if let activityID = uploader.uploadedActivityID {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("strava.upload.success")
                            .font(.subheadline)
                    }
                    .padding()
                } else {
                    Button {
                        Task { await uploader.upload(workout: workout) }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.circle.fill")
                            Text("strava.upload.button")
                        }
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }

                if let error = uploader.errorMessage {
                    VStack(spacing: 4) {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                        Button(String(localized: "list.retry")) {
                            Task { await uploader.upload(workout: workout) }
                        }
                        .font(.caption.bold())
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Header & Stats

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

            Text("detail.source \(workout.sourceRevision.source.name)")
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
            StatCard(title: String(localized: "detail.duration"), value: UnitFormatters.formatDuration(workout.duration), icon: "clock")

            if let distance = workout.totalDistance {
                StatCard(title: String(localized: "detail.distance"),
                         value: UnitFormatters.formatDistance(distance.doubleValue(for: .meter())),
                         icon: "ruler")
            }

            if let energy = workout.totalEnergyBurned {
                StatCard(title: String(localized: "detail.calories"),
                         value: UnitFormatters.formatCalories(energy.doubleValue(for: .kilocalorie())),
                         icon: "flame")
            }

            if let avgHR = viewModel?.averageHeartRate {
                StatCard(title: String(localized: "detail.avgHR"),
                         value: UnitFormatters.formatHeartRate(avgHR),
                         icon: "heart")
            }

            if let maxHR = viewModel?.maxHeartRate {
                StatCard(title: String(localized: "detail.maxHR"),
                         value: UnitFormatters.formatHeartRate(maxHR),
                         icon: "heart.fill")
            }

            if let data = viewModel?.workoutData, !data.route.isEmpty {
                StatCard(title: String(localized: "detail.gpsPoints"),
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
