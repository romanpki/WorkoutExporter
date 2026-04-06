import SwiftUI

struct ExportProgressView: View {
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("Export en cours...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
