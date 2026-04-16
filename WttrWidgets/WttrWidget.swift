import WidgetKit
import SwiftUI
import SharedKit

struct WttrWidget: Widget {
    let kind: String = "WttrWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WttrTimelineProvider()) { entry in
            WttrWidgetEntryView(entry: entry)
                .containerBackground(Color.black, for: .widget)
        }
        .configurationDisplayName("wttr")
        .description("Not the weather. Just what to do about it.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
