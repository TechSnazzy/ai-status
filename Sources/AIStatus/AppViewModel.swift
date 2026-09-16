import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published var claude: ServiceUsage = .idle
    @Published var chatgpt: ServiceUsage = .idle
    @Published var claudeCookie: String {
        didSet { KeychainHelper.save(claudeCookie, account: "claude_session_key") }
    }
    @Published var chatgptCookie: String {
        didSet { KeychainHelper.save(chatgptCookie, account: "chatgpt_session_token") }
    }
    @Published var lastUpdated: Date?

    private let service = UsageService()
    private var timer: AnyCancellable?
    private var lastRefresh: Date?

    init() {
        claudeCookie = KeychainHelper.read(account: "claude_session_key") ?? ""
        chatgptCookie = KeychainHelper.read(account: "chatgpt_session_token") ?? ""

        timer = Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refresh() }
            }
    }

    func refreshIfStale() {
        if let lastRefresh, Date().timeIntervalSince(lastRefresh) < 30 { return }
        Task { await refresh() }
    }

    func refresh() async {
        lastRefresh = Date()

        if claudeCookie.isEmpty {
            claude = .needsAuth
        } else {
            claude = .loading
            do {
                claude = try await service.fetchClaudeUsage(sessionKey: claudeCookie)
            } catch UsageServiceError.unauthorized {
                claude = .needsAuth
            } catch {
                claude = .error("Couldn't load usage")
            }
        }

        if chatgptCookie.isEmpty {
            chatgpt = .needsAuth
        } else {
            chatgpt = .loading
            do {
                chatgpt = try await service.fetchChatGPTUsage(sessionToken: chatgptCookie)
            } catch UsageServiceError.unauthorized {
                chatgpt = .needsAuth
            } catch {
                chatgpt = .error("Couldn't load usage")
            }
        }

        lastUpdated = Date()
    }
}
