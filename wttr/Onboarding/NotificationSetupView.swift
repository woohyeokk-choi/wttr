import SwiftUI
import UserNotifications
import SharedKit

struct NotificationSetupView: View {
    @Environment(PreferencesStore.self) private var preferencesStore
    @State private var selectedTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 30))!
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "bell.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("Morning weather check?")
                .font(.system(size: 28, weight: .bold))
            Text("Get a daily decision briefing at your preferred time.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 150)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    Task {
                        let center = UNUserNotificationCenter.current()
                        let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
                        preferencesStore.notificationsEnabled = granted ?? false
                        preferencesStore.notificationTime = selectedTime
                        preferencesStore.save()
                        onContinue()
                    }
                } label: {
                    Text("Enable")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    preferencesStore.notificationsEnabled = false
                    preferencesStore.save()
                    onContinue()
                } label: {
                    Text("Not Now")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .padding(.top, 56)
    }
}
