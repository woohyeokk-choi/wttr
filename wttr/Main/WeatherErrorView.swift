import SwiftUI
import SharedKit

struct WeatherErrorView: View {
    let error: WeatherProviderError
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Weather Unavailable", systemImage: "exclamationmark.triangle")
        } description: {
            Text(errorMessage)
        } actions: {
            Button("Try Again", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
    }

    private var errorMessage: String {
        switch error {
        case .locationUnavailable:
            return "Location unavailable. Please check your location settings."
        case .networkError:
            return "No internet connection. Check your connection and try again."
        case .rateLimited:
            return "Weather data temporarily unavailable. Try again in a moment."
        case .notEntitled:
            return "Weather service unavailable. Please check your subscription."
        case .unknown:
            return "Something went wrong. Pull down to refresh."
        }
    }
}
