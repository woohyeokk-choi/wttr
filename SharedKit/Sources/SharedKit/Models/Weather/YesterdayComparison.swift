import Foundation

public struct YesterdayComparison: Codable, Sendable {
    public var high: Double
    public var low: Double
    public var fetchedAt: Date

    public init(
        high: Double,
        low: Double,
        fetchedAt: Date
    ) {
        self.high = high
        self.low = low
        self.fetchedAt = fetchedAt
    }
}
