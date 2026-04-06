import SwiftUI
import HealthKit
import Charts

struct StatsView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    @State private var workouts: [HKWorkout] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    ProgressView()
                        .padding(.top, 60)
                } else {
                    VStack(spacing: 20) {
                        periodCards
                        weeklyChart
                        activityHeatMap
                    }
                    .padding()
                }
            }
            .navigationTitle(String(localized: "stats.title"))
            .task {
                await loadWorkouts()
            }
            .refreshable {
                await loadWorkouts()
            }
        }
    }

    // MARK: - Period summary cards

    private var periodCards: some View {
        VStack(spacing: 12) {
            Text("stats.thisWeek")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    title: String(localized: "stats.workouts"),
                    value: "\(weekWorkouts.count)",
                    icon: "flame"
                )
                StatCard(
                    title: String(localized: "stats.totalDistance"),
                    value: UnitFormatters.formatDistance(weekTotalDistance),
                    icon: "ruler"
                )
                StatCard(
                    title: String(localized: "stats.totalDuration"),
                    value: UnitFormatters.formatDuration(weekTotalDuration),
                    icon: "clock"
                )
                StatCard(
                    title: String(localized: "stats.totalCalories"),
                    value: UnitFormatters.formatCalories(weekTotalCalories),
                    icon: "bolt.heart"
                )
            }
        }
    }

    // MARK: - Weekly bar chart

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("stats.weeklyActivity")
                .font(.headline)

            Chart(last7DaysData, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day, unit: .day),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(.blue.gradient)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .frame(height: 160)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Activity heat map (last 12 weeks)

    private var activityHeatMap: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("stats.recentActivity")
                .font(.headline)

            let data = heatMapData
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 7), spacing: 3) {
                ForEach(data.indices, id: \.self) { index in
                    let item = data[index]
                    RoundedRectangle(cornerRadius: 2)
                        .fill(heatColor(count: item.count))
                        .aspectRatio(1, contentMode: .fit)
                }
            }

            HStack(spacing: 4) {
                Text("0")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                ForEach([0, 1, 2, 3], id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(heatColor(count: level))
                        .frame(width: 12, height: 12)
                }
                Text("3+")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Data computation

    private func loadWorkouts() async {
        isLoading = true
        do {
            let fetcher = WorkoutFetcher(healthStore: healthKitManager.healthStore)
            workouts = try await fetcher.fetchWorkouts()
        } catch {
            workouts = []
        }
        isLoading = false
    }

    private var weekWorkouts: [HKWorkout] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return workouts.filter { $0.startDate >= startOfWeek }
    }

    private var weekTotalDistance: Double {
        weekWorkouts.compactMap { $0.totalDistance?.doubleValue(for: .meter()) }.reduce(0, +)
    }

    private var weekTotalDuration: TimeInterval {
        weekWorkouts.map(\.duration).reduce(0, +)
    }

    private var weekTotalCalories: Double {
        weekWorkouts.compactMap { $0.totalEnergyBurned?.doubleValue(for: .kilocalorie()) }.reduce(0, +)
    }

    private struct DayCount: Identifiable {
        let id = UUID()
        let day: Date
        let count: Int
    }

    private var last7DaysData: [DayCount] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            let count = workouts.filter { calendar.isDate($0.startDate, inSameDayAs: day) }.count
            return DayCount(day: day, count: count)
        }
    }

    private struct HeatDay {
        let date: Date
        let count: Int
    }

    private var heatMapData: [HeatDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let totalDays = 12 * 7 // 12 weeks
        return (0..<totalDays).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            let count = workouts.filter { calendar.isDate($0.startDate, inSameDayAs: day) }.count
            return HeatDay(date: day, count: count)
        }
    }

    private func heatColor(count: Int) -> Color {
        switch count {
        case 0: Color(.systemGray5)
        case 1: Color.blue.opacity(0.3)
        case 2: Color.blue.opacity(0.6)
        default: Color.blue
        }
    }
}
