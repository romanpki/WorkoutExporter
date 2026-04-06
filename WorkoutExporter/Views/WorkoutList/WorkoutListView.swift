import SwiftUI
import HealthKit

struct WorkoutListView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    @State private var viewModel: WorkoutListViewModel?
    @State private var showFilter = false

    private var vm: WorkoutListViewModel {
        if let viewModel { return viewModel }
        let vm = WorkoutListViewModel(healthKitManager: healthKitManager)
        DispatchQueue.main.async { self.viewModel = vm }
        return vm
    }

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.isLoading && viewModel.workouts.isEmpty {
                        ProgressView("Chargement des séances...")
                    } else if let error = viewModel.errorMessage, viewModel.workouts.isEmpty {
                        ContentUnavailableView {
                            Label("Erreur", systemImage: "exclamationmark.triangle")
                        } description: {
                            Text(error)
                        } actions: {
                            Button("Réessayer") {
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
            .navigationTitle("Séances")
            .toolbar {
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
                                        Text(order.rawValue)
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
            ), prompt: "Rechercher une séance...")
            .sheet(isPresented: $showFilter) {
                if let viewModel {
                    WorkoutFilterView(viewModel: viewModel)
                }
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
        List(viewModel.filteredWorkouts, id: \.uuid) { workout in
            NavigationLink(value: workout) {
                WorkoutRowView(workout: workout)
            }
        }
        .navigationDestination(for: HKWorkout.self) { workout in
            WorkoutDetailView(workout: workout)
        }
        .listStyle(.plain)
    }
}
