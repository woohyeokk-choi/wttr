import SwiftUI
import WidgetKit
import SharedKit

struct WttrWidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    let entry: WeatherWidgetEntry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            WttrSmallWidgetView(entry: entry)
        case .systemMedium:
            if entry.isProUser {
                WttrMediumWidgetView(entry: entry)
            } else {
                WttrProUpgradeOverlay()
            }
        case .systemLarge:
            if entry.isProUser {
                WttrLargeWidgetView(entry: entry)
            } else {
                WttrProUpgradeOverlay()
            }
        default:
            WttrSmallWidgetView(entry: entry)
        }
    }
}
