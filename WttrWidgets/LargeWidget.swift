import SwiftUI
import SharedKit

/// Large (systemLarge) — Decision-first.
///
/// Header: compact context (location, temperature, vs-yesterday) as a single row.
/// Body: up to 4 decision cards (icon + headline + description).
/// Footer: upcoming weather events (rain days, UV spikes) — event summary, not grid.
struct WttrLargeWidgetView: View {
    let entry: WeatherWidgetEntry

    private var decisions: [WidgetDecision] { Array(entry.decisions.prefix(4)) }

    var body: some View {
        ZStack {
            Color("Surface")

            VStack(alignment: .leading, spacing: 10) {
                contextHeader

                Divider()

                // Decision cards
                VStack(spacing: 8) {
                    ForEach(decisions, id: \.type) { d in
                        LargeDecisionCard(decision: d)
                    }
                }

                Spacer(minLength: 0)

                // Upcoming events (rain days / UV spikes) instead of full weekly grid
                if let upcoming = upcomingEvent {
                    Divider()
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                        Text(upcoming)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(14)

            if entry.isLocationBlocked {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "location.slash.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(7)
                            .background(Circle().fill(Color.red))
                            .padding(8)
                    }
                    Spacer()
                }
            }
        }
    }

    private var contextHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.location)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: entry.condition.sfSymbolName)
                        .font(.system(size: 16))
                    Text(entry.temperature)
                        .font(.system(size: 24, weight: .bold))
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.feelsLike)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                HStack(spacing: 2) {
                    Image(systemName: vsArrow)
                        .font(.system(size: 10, weight: .semibold))
                    Text(entry.vsYesterday)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(vsColor)
            }
        }
    }

    private var upcomingEvent: String? {
        // Summarize the next rain day from weeklySnippet, else next high-UV/temp swing
        let calendar = Calendar.current
        if let rainDay = entry.weeklySnippet.first(where: { $0.precipChance >= 0.4 }) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let day = formatter.string(from: rainDay.day)
            let pct = Int(rainDay.precipChance * 100)
            return "Rain \(day) (\(pct)%)"
        }
        _ = calendar
        return nil
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

struct LargeDecisionCard: View {
    let decision: WidgetDecision

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(severityColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: decision.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(severityColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(decision.headline)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(decision.description)
                    .font(.system(size: 12))
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
