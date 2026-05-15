//
//  DefaultFavoritesRepository.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

struct DefaultFavoritesRepository: FavoritesRepository {
    private let cache: FavoritesCacheProvider

    // MARK: - LifeCycle
    init(cache: FavoritesCacheProvider) {
        self.cache = cache
    }

    // MARK: - Public
    func loadFavorites() async throws -> [FavoriteStation] {
        try await cache.loadFavorites()
            .sorted { $0.savedAt > $1.savedAt }
    }

    func isFavorite(stationID: String) async throws -> Bool {
        try await cache.loadFavorites().contains { $0.id == stationID }
    }

    func toggleFavorite(station: Station, networkID: String) async throws -> Bool {
        var favorites = try await cache.loadFavorites()

        if let index = favorites.firstIndex(where: { $0.id == station.id }) {
            favorites.remove(at: index)
            try await cache.saveFavorites(favorites)
            return false
        }

        favorites.append(FavoriteStation(station: station, networkID: networkID))
        try await cache.saveFavorites(favorites)
        return true
    }
}
