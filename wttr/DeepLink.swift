import Foundation
import SharedKit

enum DeepLinkRoute {
    case weatherForLocation(locationID: String)
    case settings
    case subscription
    case unknown
}

struct DeepLinkParser {
    func parse(_ url: URL) -> DeepLinkRoute {
        guard url.scheme == "wttr" else { return .unknown }
        switch url.host {
        case "weather":
            let locationID = url.pathComponents.dropFirst().first ?? ""
            return .weatherForLocation(locationID: locationID)
        case "settings":
            return .settings
        case "subscription":
            return .subscription
        default:
            return .unknown
        }
    }
}
