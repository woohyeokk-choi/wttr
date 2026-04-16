import SwiftUI

struct RadarView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Radar", systemImage: "map.fill")
        } description: {
            Text("Radar coming in a future update.")
        }
    }
}
