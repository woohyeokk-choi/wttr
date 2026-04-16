import SwiftUI
import SharedKit

@main
struct WttrApp: App {
    private let weatherStore: WeatherStore
    private let locationStore: LocationStore
    private let preferencesStore: PreferencesStore
    private let subscriptionStore: SubscriptionStore
    private let featureGate: DefaultFeatureGate

    init() {
        let subscriptionStore = SubscriptionStore()
        let preferencesStore = PreferencesStore()

        // WeatherKit still requires entitlement provisioning — keep mocked data for now.
        let weatherProvider: any WeatherProvider = PreviewWeatherProvider()
        // Always use the real CoreLocationProvider so iOS shows the system permission
        // dialog. `PreviewLocationProvider` auto-grants and skips the dialog entirely,
        // which hides real-world permission bugs during manual testing.
        let locationProvider: any LocationProvider = CoreLocationProvider()

        self.weatherStore = WeatherStore(weatherProvider: weatherProvider)
        self.locationStore = LocationStore(locationProvider: locationProvider)
        self.preferencesStore = preferencesStore
        self.subscriptionStore = subscriptionStore
        self.featureGate = DefaultFeatureGate(isProUserProvider: { [subscriptionStore] in subscriptionStore.isProUser })

        subscriptionStore.startTransactionListener()
        NotificationManager.shared.registerCategories()
        BackgroundTaskManager.shared.registerTasks()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(weatherStore)
                .environment(locationStore)
                .environment(preferencesStore)
                .environment(subscriptionStore)
                .environment(\.featureGate, featureGate)
                .onOpenURL { url in
                    // Deep link handling
                    let route = DeepLinkParser().parse(url)
                    // Handle route
                    _ = route
                }
        }
    }
}
