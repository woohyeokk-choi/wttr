import SwiftUI
import SharedKit

struct ContentView: View {
    @Environment(PreferencesStore.self) private var preferencesStore
    @Environment(WeatherStore.self) private var weatherStore
    @Environment(LocationStore.self) private var locationStore
    @Environment(SubscriptionStore.self) private var subscriptionStore
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if preferencesStore.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingFlow {
                    // onComplete callback
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                let subscriptionStore = subscriptionStore
                let locationStore = locationStore
                let weatherStore = weatherStore
                let preferencesStore = preferencesStore
                Task { @MainActor in
                    await subscriptionStore.checkEntitlement()
                    if let location = locationStore.selectedLocation {
                        await weatherStore.refreshIfStale(for: location, enabledDecisions: preferencesStore.enabledDecisions)
                    }
                }
            }
        }
    }
}
