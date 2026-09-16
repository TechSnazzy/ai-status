import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var claudeCookieDraft: String = ""
    @State private var chatgptCookieDraft: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Settings")
                .font(.system(size: 14, weight: .semibold))

            VStack(alignment: .leading, spacing: 6) {
                Text("Claude — sessionKey cookie")
                    .font(.system(size: 12, weight: .medium))
                Text("claude.ai → DevTools → Application → Cookies → copy the \"sessionKey\" value")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                SecureField("sk-ant-sid01-...", text: $claudeCookieDraft)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("ChatGPT — session token cookie")
                    .font(.system(size: 12, weight: .medium))
                Text("chatgpt.com → DevTools → Application → Cookies → copy the \"__Secure-next-auth.session-token\" value")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                SecureField("eyJhbGciOi...", text: $chatgptCookieDraft)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") {
                    viewModel.claudeCookie = claudeCookieDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                    viewModel.chatgptCookie = chatgptCookieDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                    dismiss()
                    Task { await viewModel.refresh() }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 360)
        .onAppear {
            claudeCookieDraft = viewModel.claudeCookie
            chatgptCookieDraft = viewModel.chatgptCookie
        }
    }
}
