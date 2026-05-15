//
//  FavoritesViewModel.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

import Combine
import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var state: FavoritesViewState = .loading
    @Published private(set) var favoriteIDs: Set<String> = []

    private let loadFavoritesUseCase: LoadFavoritesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase

    private var favorites: [FavoriteStation] = []
    private var hasLoadedFavorites = false

    // MARK: - LifeCycle
    init(
        loadFavorites: LoadFavoritesUseCase,
        toggleFavorite: ToggleFavoriteUseCase
    ) {
        self.loadFavoritesUseCase = loadFavorites
        self.toggleFavoriteUseCase = toggleFavorite
    }

    // MARK: - Public
    func loadFavorites(forceReload: Bool = false) async {
        guard forceReload || !hasLoadedFavorites else {
            publish(favorites)
            return
        }

        do {
            let favorites = try await loadFavoritesUseCase()
            hasLoadedFavorites = true
            publish(favorites)
        } catch {
            state = .error(message: "Unable to load favorites.")
        }
    }

    func isFavorite(stationID: String, networkID: String) -> Bool {
        let favoriteID = FavoriteStation.id(stationID: stationID, networkID: networkID)
        return favoriteIDs.contains(favoriteID)
    }

    func refreshFavoriteStatus() async {
        if !hasLoadedFavorites {
            await loadFavorites()
        }
    }

    func toggleFavorite(
        station: Station,
        networkID: String,
        networkName: String?,
        isFavorite: Bool
    ) async {
        await refreshFavoriteStatus()

        do {
            let favorites = try await toggleFavoriteUseCase(
                station: station,
                networkID: networkID,
                networkName: networkName,
                isFavorite: isFavorite,
                currentFavorites: favorites
            )
            publish(favorites)
        } catch {
            state = .error(message: "Unable to update favorites.")
        }
    }

    private func publish(_ favorites: [FavoriteStation]) {
        self.favorites = favorites
        favoriteIDs = Set(favorites.map(\.id))
        state = favorites.isEmpty ? .empty : .loaded(favorites)
    }
}
