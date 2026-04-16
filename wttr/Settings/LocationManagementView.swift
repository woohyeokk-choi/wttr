import SwiftUI
import SharedKit

struct LocationManagementView: View {
    @Environment(LocationStore.self) private var locationStore
    @Environment(\.featureGate) private var featureGate

    @State private var showPaywall = false

    private var canAddLocation: Bool {
        locationStore.savedLocations.count <= 1 || featureGate.isAvailable(.multipleLocations)
    }

    var body: some View {
        List {
            ForEach(Array(locationStore.savedLocations.enumerated()), id: \.offset) { index, location in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(location.city)
                            .font(.system(size: 17, weight: .medium))
                        Text(locationSubtitle(for: location))
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if index == locationStore.selectedLocationIndex {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.tint)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    locationStore.selectLocation(at: index)
                }
            }
            .onDelete { indexSet in
                for index in indexSet.sorted(by: >) {
                    locationStore.removeLocation(at: index)
                }
            }

            Section {
                Button {
                    if canAddLocation {
                        // Location search would be presented here
                        // Placeholder: adding preview location for demonstration
                    } else {
                        showPaywall = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.tint)
                        Text("Add Location")
                        if !canAddLocation {
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Manage Locations")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) {
            SubscriptionView(triggerFeature: .multipleLocations)
        }
    }

    private func locationSubtitle(for location: LocationData) -> String {
        if location.state.isEmpty {
            return location.country
        }
        return "\(location.state), \(location.country)"
    }
}
