import SwiftUI
import HealthKit

struct WorkoutFilterView: View {
    @Bindable var viewModel: WorkoutListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(String(localized: "filter.activityType")) {
                    Button {
                        viewModel.selectedActivityType = nil
                    } label: {
                        HStack {
                            Text("filter.allActivities")
                            Spacer()
                            if viewModel.selectedActivityType == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .foregroundStyle(.primary)

                    ForEach(viewModel.availableActivityTypes, id: \.rawValue) { type in
                        Button {
                            viewModel.selectedActivityType = type
                        } label: {
                            HStack {
                                Image(systemName: WorkoutTypeMapping.sfSymbol(for: type))
                                    .frame(width: 24)
                                Text(WorkoutTypeMapping.name(for: type))
                                Spacer()
                                if viewModel.selectedActivityType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle(String(localized: "filter.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
