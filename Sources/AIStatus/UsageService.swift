import Foundation

enum UsageServiceError: Error {
    case unauthorized
    case badResponse
}

struct UsageService {
    private let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"

    // MARK: - Claude

    private struct ClaudeOrg: Decodable {
        let uuid: String
    }

    private struct ClaudeLimit: Decodable {
        let group: String
        let percent: Int
        let resetsAt: String?

        enum CodingKeys: String, CodingKey {
            case group, percent
            case resetsAt = "resets_at"
        }
    }

    private struct ClaudeUsageResponse: Decodable {
        let limits: [ClaudeLimit]
    }

    func fetchClaudeUsage(sessionKey: String) async throws -> ServiceUsage {
        var orgRequest = URLRequest(url: URL(string: "https://claude.ai/api/organizations")!)
        orgRequest.setValue("sessionKey=\(sessionKey)", forHTTPHeaderField: "Cookie")
        orgRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let (orgData, orgResponse) = try await URLSession.shared.data(for: orgRequest)
        try checkAuthorized(orgResponse)
        let orgs = try JSONDecoder().decode([ClaudeOrg].self, from: orgData)

        for org in orgs {
            var usageRequest = URLRequest(url: URL(string: "https://claude.ai/api/organizations/\(org.uuid)/usage")!)
            usageRequest.setValue("sessionKey=\(sessionKey)", forHTTPHeaderField: "Cookie")
            usageRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")

            guard let (data, response) = try? await URLSession.shared.data(for: usageRequest) else { continue }
            try checkAuthorized(response)
            guard let usage = try? JSONDecoder().decode(ClaudeUsageResponse.self, from: data) else { continue }
            guard !usage.limits.isEmpty else { continue }

            let session = usage.limits.first { $0.group == "session" }
            let weekly = usage.limits.first { $0.group == "weekly" }
            guard let session, let weekly else { continue }

            return .loaded(
                session: WindowUsage(usedPercent: session.percent, resetsAt: session.resetsAt.flatMap(parseFlexibleISODate)),
                weekly: WindowUsage(usedPercent: weekly.percent, resetsAt: weekly.resetsAt.flatMap(parseFlexibleISODate))
            )
        }

        throw UsageServiceError.badResponse
    }

    // MARK: - ChatGPT

    private struct SessionResponse: Decodable {
        let accessToken: String?
    }

    private struct WhamUsageResponse: Decodable {
        struct Window: Decodable {
            let resetAt: Int
            let usedPercent: Int

            enum CodingKeys: String, CodingKey {
                case resetAt = "reset_at"
                case usedPercent = "used_percent"
            }
        }

        struct RateLimit: Decodable {
            let primaryWindow: Window?
            let secondaryWindow: Window?

            enum CodingKeys: String, CodingKey {
                case primaryWindow = "primary_window"
                case secondaryWindow = "secondary_window"
            }
        }

        let rateLimit: RateLimit

        enum CodingKeys: String, CodingKey {
            case rateLimit = "rate_limit"
        }
    }

    func fetchChatGPTUsage(sessionToken: String) async throws -> ServiceUsage {
        var sessionRequest = URLRequest(url: URL(string: "https://chatgpt.com/api/auth/session")!)
        sessionRequest.setValue("__Secure-next-auth.session-token=\(sessionToken)", forHTTPHeaderField: "Cookie")
        sessionRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let (sessionData, sessionResponse) = try await URLSession.shared.data(for: sessionRequest)
        try checkAuthorized(sessionResponse)
        let session = try JSONDecoder().decode(SessionResponse.self, from: sessionData)
        guard let accessToken = session.accessToken else {
            throw UsageServiceError.unauthorized
        }

        var usageRequest = URLRequest(url: URL(string: "https://chatgpt.com/backend-api/wham/usage")!)
        usageRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        usageRequest.setValue("__Secure-next-auth.session-token=\(sessionToken)", forHTTPHeaderField: "Cookie")
        usageRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let (usageData, usageResponse) = try await URLSession.shared.data(for: usageRequest)
        try checkAuthorized(usageResponse)
        let usage = try JSONDecoder().decode(WhamUsageResponse.self, from: usageData)

        guard let primary = usage.rateLimit.primaryWindow, let secondary = usage.rateLimit.secondaryWindow else {
            throw UsageServiceError.badResponse
        }

        return .loaded(
            session: WindowUsage(usedPercent: primary.usedPercent, resetsAt: Date(timeIntervalSince1970: TimeInterval(primary.resetAt))),
            weekly: WindowUsage(usedPercent: secondary.usedPercent, resetsAt: Date(timeIntervalSince1970: TimeInterval(secondary.resetAt)))
        )
    }

    // MARK: - Helpers

    private func checkAuthorized(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        if http.statusCode == 401 || http.statusCode == 403 {
            throw UsageServiceError.unauthorized
        }
    }
}
