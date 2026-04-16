import Foundation

public enum WeatherProviderError: Error, Sendable {
    case locationUnavailable
    case networkError(URLError)
    case rateLimited
    case notEntitled
    case unknown(description: String)
}
