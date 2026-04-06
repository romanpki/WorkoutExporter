import SwiftUI
import HealthKit

struct WorkoutRowView: View {
    let workout: HKWorkout

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: WorkoutTypeMapping.sfSymbol(for: workout.workoutActivityType))
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background(.blue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(WorkoutTypeMapping.name(for: workout.workoutActivityType))
                    .font(.headline)

                Text(DateFormatters.workoutDisplay.string(from: workout.startDate))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label(UnitFormatters.formatDurationShort(workout.duration), systemImage: "clock")

                    if let distance = workout.totalDistance {
                        let meters = distance.doubleValue(for: .meter())
                        Label(UnitFormatters.formatDistance(meters), systemImage: "ruler")
                    }

                    if let energy = workout.totalEnergyBurned {
                        let kcal = energy.doubleValue(for: .kilocalorie())
                        Label(UnitFormatters.formatCalories(kcal), systemImage: "flame")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(workout.sourceRevision.source.name)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}
