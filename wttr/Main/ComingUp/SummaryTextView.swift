import SwiftUI

struct SummaryTextView: View {
    let summary: String
    var body: some View {
        Text(summary)
            .font(.system(size: 16))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
    }
}
