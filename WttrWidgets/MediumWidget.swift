import SwiftUI
import SharedKit

/// Medium (systemMedium) — Decision-first.
///
/// Left column: top two decisions rendered as cards (icon + headline + short description).
/// Right column: compact context (location, temperature, vs-yesterday).
/// No hourly bar chart — decisions are the focus.
struct WttrMediumWidgetView: View {
    let entry: WeatherWidgetEntry

    private var topTwo: [WidgetDecision] { Array(entry.decisions.prefix(2)) }

    var body: some View {
        ZStack {
            Color("Surface")

            HStack(spacing: 12) {
                // Decision column (2 rows)
                VStack(spacing: 8) {
                    ForEach(topTwo, id: \.type) { d in
                        DecisionRow(decision: d)
                    }
                    if topTwo.count < 2 {
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Context column
                VStack(alignment: .trailing, spacing: 4) {
                    Text(entry.location)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Image(systemName: entry.condition.sfSymbolName)
                            .font(.system(size: 16))
                        Text(entry.temperature)
                            .font(.system(size: 24, weight: .bold))
                    }
                    HStack(spacing: 2) {
                        Image(systemName: vsArrow)
                            .font(.system(size: 10, weight: .semibold))
                        Text(entry.vsYesterday)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(vsColor)
                }
                .frame(width: 110, alignment: .trailing)
            }
            .padding(14)

            if entry.isLocationBlocked {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "location.slash.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(Circle().fill(Color.red))
                            .padding(6)
                    }
                    Spacer()
                }
            }
        }
    }

    private var vsArrow: String {
        switch entry.vsYesterdayDirection {
        case .warmer: return "arrow.up"
        case .colder: return "arrow.down"
        case .similar: return "equal"
        }
    }

    private var vsColor: Color {
        switch entry.vsYesterdayDirection {
        case .warmer: return .orange
        case .colder: return .blue
        case .similar: return .secondary
        }
    }
}

struct DecisionRow: View {
    let decision: WidgetDecision

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(severityColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: decision.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(severityColor)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(decision.headline)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                Text(decision.description)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
    }

    private var severityColor: Color {
        switch decision.severity {
        case .safe: return Color("Safe")
        case .caution: return Color("Caution")
        case .warning: return Color("Warning")
        case .danger: return Color("Danger")
        }
    }
}
