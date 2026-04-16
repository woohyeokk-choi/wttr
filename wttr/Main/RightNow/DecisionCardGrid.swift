import SwiftUI
import SharedKit

struct DecisionCardGrid: View {
    let decisions: [any Decision]
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var columns: [GridItem] {
        if dynamicTypeSize >= .accessibility1 {
            return [GridItem(.flexible())]
        }
        return [GridItem(.adaptive(minimum: 160))]
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(decisions.enumerated()), id: \.offset) { _, decision in
                DecisionCardView(decision: decision)
            }
        }
    }
}
