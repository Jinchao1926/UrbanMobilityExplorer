//
//  FavoritesView.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct FavoritesView: View {
    let stations: [Station]
    @Binding var favoriteStationIDs: Set<String>

    private var favoriteStations: [Station] {
        stations.filter { favoriteStationIDs.contains($0.id) }
    }

    var body: some View {
        List {
            ForEach(favoriteStations) { station in
                NavigationLink {
                    StationDetailView(station: station, favoriteStationIDs: $favoriteStationIDs)
                } label: {
                    StationRowView(station: station, isFavorite: true)
                }
                .accessibilityIdentifier("favorite-row-\(station.id)")
            }
        }
        .navigationTitle("Favorites")
        .overlay {
            if favoriteStations.isEmpty {
                EmptyStateView(
                    title: "No Favorites",
                    systemImage: "star",
                    message: "Favorite stations from the detail page for quick access."
                )
            }
        }
    }
}
