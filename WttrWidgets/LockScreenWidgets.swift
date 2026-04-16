import SwiftUI
import WidgetKit
import SharedKit

// MARK: - accessoryCircular

struct WttrCircularLockScreenView: View {
    let entry: WeatherWidgetEntry

    private var primary: WidgetDecision? { entry.decisions.first }

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            if let d = primary {
                VStack(spacing: 2) {
                    Image(systemName: d.icon)
                        .font(.system(size: 18, weight: .semibold))
                    Text(d.shortLabel)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            } else {
                Image(systemName: "cloud.sun.fill")
            }
        }
        .widgetAccentable()
        .accessibilityLabel(primary?.headline ?? "wttr")
    }
}

// MARK: - accessoryRectangular

struct WttrRectangularLockScreenView: View {
    let entry: WeatherWidgetEntry

    private var primary: WidgetDecision? { entry.decisions.first }

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            if let d = primary {
                Image(systemName: d.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .widgetAccentable()
                VStack(alignment: .leading, spacing: 1) {
                    Text(d.headline)
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                    Text(d.description)
                        .font(.system(size: 11))
                        .lineLimit(1)
                    Text("\(entry.location) · \(entry.temperature)")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } else {
                Text("wttr")
            }
        }
        .accessibilityLabel(Text("\(primary?.headline ?? "wttr"). \(entry.location), \(entry.temperature)"))
    }
}

// MARK: - accessoryInline

struct WttrInlineLockScreenView: View {
    let entry: WeatherWidgetEntry

    var body: some View {
        if let d = entry.decisions.first {
            Label {
                Text("\(d.shortLabel) · \(entry.temperature)")
            } icon: {
                Image(systemName: d.icon)
            }
        } else {
            Text("wttr \(entry.temperature)")
        }
    }
}

// MARK: - Widget definition

struct WttrLockScreenWidget: Widget {
    let kind: String = "WttrLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WttrTimelineProvider()) { entry in
            WttrLockScreenEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("wttr Lock Screen")
        .description("Your top weather decision on the lock screen.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct WttrLockScreenEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WeatherWidgetEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            WttrCircularLockScreenView(entry: entry)
        case .accessoryRectangular:
            WttrRectangularLockScreenView(entry: entry)
        case .accessoryInline:
            WttrInlineLockScreenView(entry: entry)
        default:
            WttrInlineLockScreenView(entry: entry)
        }
    }
}
