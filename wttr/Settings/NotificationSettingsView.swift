import SwiftUI
import UserNotifications
import SharedKit

struct NotificationSettingsView: View {
    @Environment(PreferencesStore.self) private var preferencesStore
    @Environment(SubscriptionStore.self) private var subscriptionStore
    @Environment(\.featureGate) private var featureGate

    @State private var selectedTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 30)) ?? Date()
    @State private var showPaywall = false

    var body: some View {
        List {
            Section {
                Toggle("Morning Briefing", isOn: Binding(
                    get: { preferencesStore.notificationsEnabled },
                    set: { newValue in
                        if newValue {
                            requestNotificationPermission()
                        } else {
                            preferencesStore.notificationsEnabled = false
                            preferencesStore.save()
                        }
                    }
                ))

                if preferencesStore.notificationsEnabled {
                    DatePicker(
                        "Briefing Time",
                        selection: Binding(
                            get: { preferencesStore.notificationTime ?? selectedTime },
                            set: { newTime in
                                selectedTime = newTime
                                preferencesStore.notificationTime = newTime
                                preferencesStore.save()
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
            } header: {
                Text("Morning Briefing")
            } footer: {
                Text("Receive a daily weather decision summary at your preferred time.")
                    .font(.footnote)
            }

            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("Event Alerts")
                            if !featureGate.isAvailable(.eventAlerts) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Text("Alerts for weather events like storms or heat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if featureGate.isAvailable(.eventAlerts) {
                        Toggle("", isOn: .constant(false))
                            .labelsHidden()
                    } else {
                        Button("Pro") {
                            showPaywall = true
                        }
                        .font(.system(size: 13, weight: .medium))
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if !featureGate.isAvailable(.eventAlerts) {
                        showPaywall = true
                    }
                }
            } header: {
                Text("Event Alerts")
            }
        }
        .navigationTitle("Morning Briefing")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) {
            SubscriptionView(triggerFeature: .eventAlerts)
        }
        .onAppear {
            if let saved = preferencesStore.notificationTime {
                selectedTime = saved
            }
        }
    }

    private func requestNotificationPermission() {
        let preferencesStore = preferencesStore
        let time = selectedTime
        Task { @MainActor in
            let center = UNUserNotificationCenter.current()
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            preferencesStore.notificationsEnabled = granted
            if granted {
                preferencesStore.notificationTime = time
            }
            preferencesStore.save()
        }
    }
}
