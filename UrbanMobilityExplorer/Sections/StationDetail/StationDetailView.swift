//
//  StationDetailView.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct StationDetailView: View {
    let station: Station
    @Binding var favoriteStationIDs: Set<String>

    private var isFavorite: Bool {
        favoriteStationIDs.contains(station.id)
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(station.name)
                            .font(.title2.weight(.semibold))

                        Spacer()

                        AvailabilityBadge(level: station.availabilityLevel)
                    }

                    Text(station.neighborhood)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Current status") {
                DetailMetricRow(title: "Available bikes", value: "\(station.availableBikes)")
                DetailMetricRow(title: "Open docks", value: "\(station.openDocks)")
                DetailMetricRow(title: "Last updated", value: station.lastUpdated)
            }

            Section("Location") {
                DetailMetricRow(title: "Latitude", value: station.latitude.formatted(.number.precision(.fractionLength(4))))
                DetailMetricRow(title: "Longitude", value: station.longitude.formatted(.number.precision(.fractionLength(4))))
            }
        }
        .navigationTitle("Station Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Label(
                        isFavorite ? "Remove Favorite" : "Toggle Favorite",
                        systemImage: isFavorite ? "star.fill" : "star"
                    )
                }
                .accessibilityLabel("Toggle Favorite")
            }
        }
    }

    private func toggleFavorite() {
        if isFavorite {
            favoriteStationIDs.remove(station.id)
        } else {
            favoriteStationIDs.insert(station.id)
        }
    }
}
