import Foundation
import UserNotifications
import SharedKit

final class NotificationManager: @unchecked Sendable {
    static let shared = NotificationManager()
    static let morningBriefingTaskID = "com.wttr.app.morningBriefing"

    private init() {}

    func registerCategories() {
        let center = UNUserNotificationCenter.current()

        let morningBriefing = UNNotificationCategory(
            identifier: "MORNING_BRIEFING",
            actions: [
                UNNotificationAction(identifier: "OPEN", title: "Open", options: .foreground),
                UNNotificationAction(identifier: "SNOOZE", title: "Snooze 30min", options: [])
            ],
            intentIdentifiers: [], options: []
        )

        let weatherAlert = UNNotificationCategory(
            identifier: "WEATHER_ALERT",
            actions: [
                UNNotificationAction(identifier: "OPEN", title: "Open", options: .foreground),
                UNNotificationAction(identifier: "DISMISS", title: "Dismiss", options: .destructive)
            ],
            intentIdentifiers: [], options: []
        )

        center.setNotificationCategories([morningBriefing, weatherAlert])
    }

    func makeMorningBriefingContent(decisions: [any Decision]) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Your morning weather check"
        content.body = decisions
            .prefix(4)
            .map { $0.headline }
            .joined(separator: " ")
        content.sound = .default
        content.categoryIdentifier = "MORNING_BRIEFING"
        content.threadIdentifier = "morning-briefing"
        content.userInfo = ["route": "weather/current"]
        return content
    }

    func scheduleMorningBriefing(at time: Date, decisions: [any Decision]) {
        guard !decisions.isEmpty else { return }
        let content = makeMorningBriefingContent(decisions: decisions)
        let trigger = nextCalendarTrigger(for: time)
        let request = UNNotificationRequest(
            identifier: "morning-briefing-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { _ in }
    }

    func scheduleSnooze(content: UNNotificationContent) {
        let mutableContent = content.mutableCopy() as! UNMutableNotificationContent
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false)
        let request = UNNotificationRequest(
            identifier: "morning-briefing-snooze",
            content: mutableContent,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { _ in }
    }

    func cancelPendingMorningBriefings() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .filter { $0.content.categoryIdentifier == "MORNING_BRIEFING" }
                .map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    private func nextCalendarTrigger(for time: Date) -> UNCalendarNotificationTrigger {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }
}
