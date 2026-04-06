import SwiftUI

struct HealthKitPermissionView: View {
    @Environment(HealthKitManager.self) private var healthKitManager

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "heart.text.clipboard")
                .font(.system(size: 80))
                .foregroundStyle(.red.gradient)

            VStack(spacing: 12) {
                Text("WorkoutExporter")
                    .font(.largeTitle.bold())

                Text("Exportez vos séances sportives depuis Apple Health dans le format de votre choix.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 16) {
                PermissionRow(icon: "figure.run", color: .green,
                              title: "Séances d'entraînement",
                              subtitle: "Accéder à vos workouts enregistrés")
                PermissionRow(icon: "location", color: .blue,
                              title: "Tracés GPS",
                              subtitle: "Lire les parcours de vos séances")
                PermissionRow(icon: "heart", color: .red,
                              title: "Données physiologiques",
                              subtitle: "FC, cadence, puissance, vitesse")
            }
            .padding(.horizontal, 24)

            Spacer()

            if let error = healthKitManager.authorizationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            if !healthKitManager.isAvailable {
                Text("HealthKit n'est pas disponible sur cet appareil.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Button {
                Task {
                    await healthKitManager.requestAuthorization()
                }
            } label: {
                Text("Autoriser l'accès à Santé")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!healthKitManager.isAvailable)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

private struct PermissionRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
