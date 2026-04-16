import Foundation

extension Date {
    /// Returns a short time string, e.g. "3 PM", "15:00"
    public func shortTimeString(in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Returns weekday name, e.g. "Monday" or "Mon"
    public func weekdayName(abbreviated: Bool = false, in locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = abbreviated ? "EEE" : "EEEE"
        return formatter.string(from: self)
    }

    /// Returns medium date string, e.g. "Apr 16"
    public func mediumDateString(in locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
}
