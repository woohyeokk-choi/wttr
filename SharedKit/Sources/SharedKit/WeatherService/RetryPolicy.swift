import Foundation

public struct RetryPolicy: Sendable {
    public static let maxAttempts: Int = 3
    public static let baseDelay: TimeInterval = 1.0
    public static let backoffMultiplier: Double = 2.0

    public static func isRetryable(_ error: WeatherProviderError) -> Bool {
        switch error {
        case .networkError, .unknown:
            return true
        case .rateLimited, .notEntitled, .locationUnavailable:
            return false
        }
    }

    public static func delay(forAttempt attempt: Int) -> TimeInterval {
        baseDelay * pow(backoffMultiplier, Double(attempt - 1))
    }
}
