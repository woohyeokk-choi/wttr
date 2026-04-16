public protocol Decision: Codable, Sendable {
    var type: DecisionType { get }
    var severity: DecisionSeverity { get }
    var headline: String { get }
    var description: String { get }
    var icon: String { get }
}
