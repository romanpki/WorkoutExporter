import SwiftUI
import HealthKit

struct WorkoutListView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    @State private var viewModel: WorkoutListViewModel?
    @State private var showFilter = false
    @State private var showSettings = false
    @State private var isSelecting = false
    @State private var selectedWorkouts: Set<UUID> = []

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.isLoading && viewModel.workouts.isEmpty {
                        ProgressView(String(localized: "list.loading"))
                    } else if let error = viewModel.errorMessage, viewModel.workouts.isEmpty {
                        ContentUnavailableView {
                            Label(String(localized: "list.error"), systemImage: "exclamationmark.triangle")
                        } description: {
                            Text(error)
                        } actions: {
                            Button(String(localized: "list.retry")) {
                                Task { await viewModel.loadWorkouts() }
                            }
                        }
                    } else if viewModel.filteredWorkouts.isEmpty {
                        ContentUnavailableView.search(text: viewModel.searchText)
                    } else {
                        workoutList(viewModel)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(String(localized: "list.title"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let viewModel, !viewModel.filteredWorkouts.isEmpty {
                        Button {
                            withAnimation {
                                isSelecting.toggle()
                                if !isSelecting { selectedWorkouts.removeAll() }
                            }
                        } label: {
                            Text(isSelecting ? "OK" : String(localized: "batch.export"))
                                .font(.subheadline)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let viewModel {
                        Menu {
                            ForEach(WorkoutListViewModel.SortOrder.allCases, id: \.self) { order in
                                Button {
                                    viewModel.sortOrder = order
                                } label: {
                                    HStack {
                                        Text(order.displayName)
                                        if viewModel.sortOrder == order {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }
                }
            }
            .searchable(text: Binding(
                get: { viewModel?.searchText ?? "" },
                set: { viewModel?.searchText = $0 }
            ), prompt: Text("list.search"))
            .sheet(isPresented: $showFilter) {
                if let viewModel {
                    WorkoutFilterView(viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .task {
                if viewModel == nil {
                    viewModel = WorkoutListViewModel(healthKitManager: healthKitManager)
                }
                if let viewModel, viewModel.workouts.isEmpty {
                    await viewModel.loadWorkouts()
                }
            }
            .refreshable {
                await viewModel?.loadWorkouts()
            }
        }
    }

    private func workoutList(_ viewModel: WorkoutListViewModel) -> some View {
        VStack(spacing: 0) {
            if isSelecting {
                batchToolbar(viewModel)
            }

            List(viewModel.filteredWorkouts, id: \.uuid) { workout in
                if isSelecting {
                    HStack {
                        Image(systemName: selectedWorkouts.contains(workout.uuid) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedWorkouts.contains(workout.uuid) ? .blue : .secondary)
                            .font(.title3)

                        WorkoutRowView(workout: workout)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedWorkouts.contains(workout.uuid) {
                            selectedWorkouts.remove(workout.uuid)
                        } else {
                            selectedWorkouts.insert(workout.uuid)
                        }
                    }
                } else {
                    NavigationLink(value: workout) {
                        WorkoutRowView(workout: workout)
                    }
                }
            }
            .navigationDestination(for: HKWorkout.self) { workout in
                WorkoutDetailView(workout: workout)
            }
            .listStyle(.plain)
        }
    }

    private func batchToolbar(_ viewModel: WorkoutListViewModel) -> some View {
        HStack {
            Button {
                if selectedWorkouts.count == viewModel.filteredWorkouts.count {
                    selectedWorkouts.removeAll()
                } else {
                    selectedWorkouts = Set(viewModel.filteredWorkouts.map(\.uuid))
                }
            } label: {
                Text(selectedWorkouts.count == viewModel.filteredWorkouts.count
                     ? String(localized: "batch.deselectAll")
                     : String(localized: "batch.selectAll"))
                    .font(.subheadline)
            }

            Spacer()

            Text("batch.selected \(selectedWorkouts.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            if !selectedWorkouts.isEmpty {
                ShareLink(items: []) {
                    Label(String(localized: "batch.export"), systemImage: "square.and.arrow.up")
                        .font(.subheadline.bold())
                }
                .disabled(true) // Placeholder — real batch export handled by BatchExportView
                .hidden()

                NavigationLink {
                    BatchExportView(
                        workouts: viewModel.filteredWorkouts.filter { selectedWorkouts.contains($0.uuid) },
                        healthKitManager: healthKitManager
                    )
                } label: {
                    Label(String(localized: "batch.export"), systemImage: "square.and.arrow.up")
                        .font(.subheadline.bold())
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }
}
