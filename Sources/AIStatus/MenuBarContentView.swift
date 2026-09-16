import SwiftUI
import AppKit

private enum Tab: String, CaseIterable {
    case claude = "Claude"
    case chatgpt = "Codex"
}

struct MenuBarContentView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedTab: Tab = .claude
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(12)

            Divider()

            Group {
                switch selectedTab {
                case .claude:
                    UsageDetailView(usage: viewModel.claude) { showingSettings = true }
                case .chatgpt:
                    UsageDetailView(usage: viewModel.chatgpt) { showingSettings = true }
                }
            }
            .frame(minHeight: 130)

            Divider()

            HStack {
                if let lastUpdated = viewModel.lastUpdated {
                    Text("Updated \(Formatting.resetLabel(lastUpdated))")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    Task { await viewModel.refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)

                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.plain)

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "power")
                }
                .buttonStyle(.plain)
            }
            .padding(10)
        }
        .frame(width: 260)
        .onAppear { viewModel.refreshIfStale() }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
    }
}
