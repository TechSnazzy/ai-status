import Foundation

enum Formatting {
    static func resetLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        if calendar.isDateInToday(date) {
            return "Today, \(timeFormatter.string(from: date))"
        }
        if calendar.isDateInTomorrow(date) {
            return "Tomorrow, \(timeFormatter.string(from: date))"
        }
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE, h:mm a"
        return dayFormatter.string(from: date)
    }
}
