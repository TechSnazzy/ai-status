import Foundation

struct WindowUsage: Equatable {
    let usedPercent: Int
    let resetsAt: Date?
}

enum ServiceUsage: Equatable {
    case idle
    case loading
    case needsAuth
    case error(String)
    case loaded(session: WindowUsage, weekly: WindowUsage)
}

/// Parses timestamps like "2026-09-16T21:30:00.864664+00:00" (arbitrary-precision
/// fractional seconds, which ISO8601DateFormatter chokes on) by trimming the
/// fractional part before handing off to the standard parser.
func parseFlexibleISODate(_ raw: String) -> Date? {
    guard let dotIndex = raw.firstIndex(of: ".") else {
        return ISO8601DateFormatter().date(from: raw)
    }
    let base = raw[raw.startIndex..<dotIndex]
    guard let signIndex = raw[dotIndex...].firstIndex(where: { $0 == "+" || $0 == "-" }) else {
        return ISO8601DateFormatter().date(from: raw)
    }
    let offset = raw[signIndex...]
    let cleaned = String(base) + String(offset)
    return ISO8601DateFormatter().date(from: cleaned)
}
