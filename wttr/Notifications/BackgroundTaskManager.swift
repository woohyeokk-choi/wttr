import BackgroundTasks
import SharedKit
import WidgetKit

private struct UncheckedSendableBox<T>: @unchecked Sendable {
    let value: T
}

final class BackgroundTaskManager: @unchecked Sendable {
    static let shared = BackgroundTaskManager()
    private init() {}

    func registerTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: NotificationManager.morningBriefingTaskID,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            let box = UncheckedSendableBox(value: refreshTask)
            Task { [box] in
                await BackgroundTaskManager.shared.handleMorningBriefingTask(box.value)
            }
        }
    }

    func scheduleBackgroundFetch(for notificationTime: Date?) {
        let request = BGAppRefreshTaskRequest(identifier: NotificationManager.morningBriefingTaskID)
        if let time = notificationTime {
            let targetDate = nextOccurrence(of: time, offsetBy: -1800)
            request.earliestBeginDate = targetDate
        } else {
            request.earliestBeginDate = Date(timeIntervalSinceNow: 6 * 3600)
        }
        try? BGTaskScheduler.shared.submit(request)
    }

    private func handleMorningBriefingTask(_ task: BGAppRefreshTask) async {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // In production, this would fetch weather and evaluate decisions.
        // For now, schedule the next fetch and complete.
        let defaults = UserDefaults(suiteName: "group.com.wttr.app")
        let timeInterval = defaults?.double(forKey: "preferences.notificationTime") ?? 0
        let notificationTime = timeInterval > 0 ? Date(timeIntervalSince1970: timeInterval) : nil

        scheduleBackgroundFetch(for: notificationTime)
        task.setTaskCompleted(success: true)
    }

    private func nextOccurrence(of time: Date, offsetBy seconds: TimeInterval) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        var target = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime) ?? Date()
        target = target.addingTimeInterval(seconds)
        if target < Date() {
            target = calendar.date(byAdding: .day, value: 1, to: target) ?? target
        }
        return target
    }
}
