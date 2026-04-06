import SwiftUI

struct ExportProgressView: View {
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("export.inProgress")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
