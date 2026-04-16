import SwiftUI
import SharedKit

struct WeatherPageView: View {
    let location: LocationData
    @Environment(WeatherStore.self) private var weatherStore
    @Environment(PreferencesStore.self) private var preferencesStore
    @State private var showStaleBanner = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if weatherStore.isLoading && weatherStore.currentWeather == nil {
                LoadingSkeletonView()
            } else if let error = weatherStore.error, weatherStore.currentWeather == nil {
                WeatherErrorView(error: error) {
                    let weatherStore = weatherStore
                    let preferencesStore = preferencesStore
                    let location = location
                    Task { await weatherStore.fetchWeather(for: location, enabledDecisions: preferencesStore.enabledDecisions) }
                }
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 24) {
                        if weatherStore.error != nil && weatherStore.currentWeather != nil {
                            BannerView(message: "Couldn't refresh weather. Pull down to try again.", style: .warning, isVisible: $showStaleBanner)
                        }
                        HeaderView(location: location)
                        RightNowSection()
                        ComingUpSection()
                        TodaySection()
                        ThisWeekSection()
                    }
                    .padding(.bottom, 32)
                }
                .refreshable {
                    let weatherStore = weatherStore
                    let preferencesStore = preferencesStore
                    let location = location
                    await weatherStore.fetchWeather(for: location, enabledDecisions: preferencesStore.enabledDecisions)
                }
            }
        }
    }
}
