import SwiftUI

struct UsageDetailView: View {
    let usage: ServiceUsage
    let onOpenSettings: () -> Void

    var body: some View {
        switch usage {
        case .idle, .loading:
            VStack {
                Spacer(minLength: 24)
                ProgressView()
                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity)

        case .needsAuth:
            VStack(spacing: 10) {
                Spacer(minLength: 12)
                Text("Not connected")
                    .font(.system(size: 13, weight: .medium))
                Text("Add your session cookie in Settings to see usage.")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Open Settings", action: onOpenSettings)
                    .controlSize(.small)
                Spacer(minLength: 12)
            }
            .padding(.horizontal, 16)

        case .error(let message):
            VStack(spacing: 10) {
                Spacer(minLength: 12)
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 12)
            }

        case .loaded(let session, let weekly):
            VStack(alignment: .leading, spacing: 16) {
                UsageRow(title: "Current session", usage: session)
                UsageRow(title: "This week", usage: weekly)
            }
            .padding(16)
        }
    }
}

private struct UsageRow: View {
    let title: String
    let usage: WindowUsage

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Text("\(usage.usedPercent)% used")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: Double(min(max(usage.usedPercent, 0), 100)), total: 100)
                .tint(color(for: usage.usedPercent))

            if let resetsAt = usage.resetsAt {
                Text("Resets \(Formatting.resetLabel(resetsAt))")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func color(for percent: Int) -> Color {
        switch percent {
        case ..<70: return .accentColor
        case 70..<90: return .orange
        default: return .red
        }
    }
}
