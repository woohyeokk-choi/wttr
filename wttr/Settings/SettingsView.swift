import SwiftUI
import SharedKit

struct SettingsView: View {
    @Environment(PreferencesStore.self) private var preferencesStore
    @Environment(SubscriptionStore.self) private var subscriptionStore
    @Environment(\.featureGate) private var featureGate

    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                Section("Decisions") {
                    NavigationLink("Decision Cards") { DecisionPreferencesView() }
                }
                Section("Notifications") {
                    NavigationLink("Morning Briefing") { NotificationSettingsView() }
                }
                Section("Locations") {
                    NavigationLink("Manage Locations") { LocationManagementView() }
                }
                Section("Display") {
                    NavigationLink("Units") { UnitsView() }
                }
                Section {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack {
                            Text(subscriptionStore.isProUser ? "wttr Pro" : "Upgrade to Pro")
                            Spacer()
                            if !subscriptionStore.isProUser {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Section {
                    NavigationLink("About") { AboutView() }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                SubscriptionView(triggerFeature: nil)
            }
        }
    }
}
