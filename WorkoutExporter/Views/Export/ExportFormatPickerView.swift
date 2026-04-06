import SwiftUI
import HealthKit

struct ExportFormatPickerView: View {
    @Bindable var viewModel: ExportViewModel
    let workout: HKWorkout
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("export.chooseFormat")
                    .font(.headline)
                    .padding(.top)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(ExportFormat.allCases) { format in
                        FormatCard(
                            format: format,
                            isSelected: viewModel.selectedFormat == format
                        ) {
                            viewModel.selectedFormat = format
                        }
                    }
                }
                .padding(.horizontal)

                Text(viewModel.selectedFormat.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()

                if viewModel.isExporting {
                    ExportProgressView()
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 8) {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                        Button(String(localized: "list.retry")) {
                            Task {
                                await viewModel.exportWorkout(workout, format: viewModel.selectedFormat)
                                if viewModel.errorMessage == nil { dismiss() }
                            }
                        }
                        .font(.caption.bold())
                    }
                    .padding(.horizontal)
                }

                Button {
                    Task {
                        await viewModel.exportWorkout(workout, format: viewModel.selectedFormat)
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                } label: {
                    Label("export.button \(viewModel.selectedFormat.displayName)", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(viewModel.isExporting)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "export.cancel")) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

private struct FormatCard: View {
    let format: ExportFormat
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: format.iconName)
                    .font(.title2)

                Text(format.displayName)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.blue.opacity(0.15) : Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .foregroundStyle(isSelected ? .blue : .primary)
    }
}
