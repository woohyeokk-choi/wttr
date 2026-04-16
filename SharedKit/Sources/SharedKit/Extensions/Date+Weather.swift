import Foundation

extension Date {
    /// Midnight of previous calendar day in given timezone
    public func yesterdayStart(in timeZone: TimeZone) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let startOfToday = calendar.startOfDay(for: self)
        return calendar.date(byAdding: .day, value: -1, to: startOfToday)!
    }

    /// 23:59:59 of previous calendar day in given timezone
    public func yesterdayEnd(in timeZone: TimeZone) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let startOfToday = calendar.startOfDay(for: self)
        return startOfToday.addingTimeInterval(-1)
    }

    /// True if same calendar day as `other` in given timezone
    public func isSameDay(as other: Date, in timeZone: TimeZone) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.isDate(self, inSameDayAs: other)
    }
}
