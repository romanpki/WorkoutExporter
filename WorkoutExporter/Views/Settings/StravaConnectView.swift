import SwiftUI

struct StravaConnectView: View {
    @Environment(StravaAuthManager.self) private var stravaAuth

    var body: some View {
        Section {
            if stravaAuth.isConnected {
                connectedView
            } else {
                disconnectedView
            }

            if let error = stravaAuth.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        } header: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(.orange)
                Text("Strava")
            }
        }
    }

    private var connectedView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text("strava.connected")
                        .font(.subheadline.bold())
                    if let athlete = stravaAuth.athlete {
                        Text(athlete.fullName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }

            Button(role: .destructive) {
                Task { await stravaAuth.disconnect() }
            } label: {
                Text("strava.disconnect")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var disconnectedView: some View {
        VStack(spacing: 12) {
            Text("strava.description")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                Task { await stravaAuth.authorize() }
            } label: {
                HStack {
                    Image(systemName: "link")
                    Text("strava.connect")
                }
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.orange)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }
}
