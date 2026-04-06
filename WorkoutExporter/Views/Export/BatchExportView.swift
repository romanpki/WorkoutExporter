import SwiftUI
import HealthKit

struct BatchExportView: View {
    let workouts: [HKWorkout]
    let healthKitManager: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: ExportFormat = .gpx
    @State private var isExporting = false
    @State private var progress: Double = 0
    @State private var errorMessage: String?
    @State private var exportedURL: URL?
    @State private var showShareSheet = false

    var body: some View {
        VStack(spacing: 20) {
            Text("export.chooseFormat")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(ExportFormat.allCases) { format in
                    Button {
                        selectedFormat = format
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: format.iconName)
                                .font(.title2)
                            Text(format.displayName)
                                .font(.caption.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedFormat == format ? Color.blue.opacity(0.15) : Color(.secondarySystemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(selectedFormat == format ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .foregroundStyle(selectedFormat == format ? .blue : .primary)
                }
            }
            .padding(.horizontal)

            Text("batch.selected \(workouts.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if isExporting {
                VStack(spacing: 8) {
                    ProgressView(value: progress)
                        .padding(.horizontal)
                    Text("export.inProgress")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let error = errorMessage {
                VStack(spacing: 8) {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                    Button(String(localized: "list.retry")) {
                        Task { await startExport() }
                    }
                    .font(.caption.bold())
                }
            }

            Spacer()

            Button {
                Task { await startExport() }
            } label: {
                Label("export.button \(selectedFormat.displayName)", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(isExporting)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationTitle(String(localized: "batch.export"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedURL {
                ShareSheetView(items: [url])
            }
        }
    }

    private func startExport() async {
        isExporting = true
        errorMessage = nil
        progress = 0

        do {
            let tempDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("batch_\(UUID().uuidString)")
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

            let coordinator = ExportCoordinator(healthKitManager: healthKitManager)

            for (index, workout) in workouts.enumerated() {
                let (data, fileName) = try await coordinator.export(workout: workout, format: selectedFormat)
                let fileURL = tempDir.appendingPathComponent(fileName)
                try data.write(to: fileURL)
                progress = Double(index + 1) / Double(workouts.count)
            }

            // Create ZIP
            let zipURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("WorkoutExport_\(DateFormatters.fileName.string(from: Date())).zip")

            // Remove old zip if exists
            try? FileManager.default.removeItem(at: zipURL)

            let coordinator2 = NSFileCoordinator()
            var error: NSError?
            coordinator2.coordinate(readingItemAt: tempDir, options: .forUploading, error: &error) { zipTempURL in
                try? FileManager.default.moveItem(at: zipTempURL, to: zipURL)
            }

            if let error { throw error }

            // Clean up temp dir
            try? FileManager.default.removeItem(at: tempDir)

            exportedURL = zipURL
            showShareSheet = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isExporting = false
    }
}
