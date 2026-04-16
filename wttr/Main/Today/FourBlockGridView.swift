import SwiftUI
import SharedKit

struct TimeBlock {
    let periodName: String
    let condition: WeatherConditionType
    let icon: String
    let low: Double
    let high: Double
}

struct FourBlockGridView: View {
    let hourlyForecast: [HourlyForecast]
    @Environment(\.colorSchemeContrast) private var contrast

    private var blocks: [TimeBlock] {
        // Morning 6-12, Afternoon 12-18, Evening 18-22, Night 22-6
        let periods: [(String, ClosedRange<Int>)] = [
            ("Morn", 6...11), ("Aftn", 12...17), ("Evng", 18...21), ("Night", 22...29)  // 29 wraps
        ]
        let calendar = Calendar.current
        return periods.map { name, range in
            let hours = hourlyForecast.filter { h in
                let hour = calendar.component(.hour, from: h.hour)
                if range.upperBound > 23 { return hour >= range.lowerBound || hour <= (range.upperBound - 24) }
                return range.contains(hour)
            }
            let temps = hours.map(\.condition.temperature)
            let condition = hours.first?.condition.condition ?? .clear
            return TimeBlock(
                periodName: name,
                condition: condition,
                icon: condition.sfSymbolName,
                low: temps.min() ?? 0,
                high: temps.max() ?? 0
            )
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                if index > 0 { Divider() }
                TimeBlockView(block: block)
            }
        }
        .background(Color("Surface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            if contrast == .increased {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.3), lineWidth: 1)
            }
        }
    }
}

struct TimeBlockView: View {
    let block: TimeBlock
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        VStack(spacing: 6) {
            Text(block.periodName.uppercased())
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            Image(systemName: block.icon)
                .font(.system(size: 24))
                .symbolRenderingMode(.multicolor)
            Text("\(Int(block.low.rounded()))–\(Int(block.high.rounded()))°")
                .font(.system(size: 15))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(block.periodName). \(block.condition.displayName). \(Int(block.low.rounded())) to \(Int(block.high.rounded())) degrees.")
    }
}
