import SwiftUI
import HealthKit

struct WorkoutIcon: View {
    let activityType: HKWorkoutActivityType
    var size: CGFloat = 32

    var body: some View {
        Image(systemName: WorkoutTypeMapping.sfSymbol(for: activityType))
            .font(.system(size: size * 0.5))
            .foregroundStyle(.blue)
            .frame(width: size, height: size)
            .background(.blue.opacity(0.1))
            .clipShape(Circle())
    }
}
