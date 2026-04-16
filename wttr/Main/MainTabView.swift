import SwiftUI

enum TabSelection: Int {
    case location = 0, stats, radar, settings
}

struct MainTabView: View {
    @State private var selectedTab: TabSelection = .location

    var body: some View {
        TabView(selection: $selectedTab) {
            LocationView()
                .tag(TabSelection.location)
                .tabItem { Label("Location", systemImage: "location.fill") }
            StatsView()
                .tag(TabSelection.stats)
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
            RadarView()
                .tag(TabSelection.radar)
                .tabItem { Label("Radar", systemImage: "map.fill") }
            SettingsView()
                .tag(TabSelection.settings)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}
