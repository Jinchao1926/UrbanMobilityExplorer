//
//  FavoritesView.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        List {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading favorites")
            case .loaded(let favorites):
                ForEach(favorites) { favorite in
                    NavigationLink {
                        StationDetailView(
                            station: favorite.station,
                            networkID: favorite.networkID,
                            networkName: favorite.networkName,
                            favoritesViewModel: viewModel
                        )
                    } label: {
                        StationCell(station: favorite.station, isFavorite: true)
                    }
                    .accessibilityIdentifier("favorite-row-\(favorite.id)")
                }
            case .empty:
                EmptyView()
            case .error(let message):
                Label(message, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Favorites")
        .overlay {
            if case .empty = viewModel.state {
                EmptyStateView(
                    title: "No Favorites",
                    systemImage: "star",
                    message: "Favorite stations from the detail page for quick access."
                )
            }
        }
        .task {
            await viewModel.loadFavorites()
        }
    }
}
