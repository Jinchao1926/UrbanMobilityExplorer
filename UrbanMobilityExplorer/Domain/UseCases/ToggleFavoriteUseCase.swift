//
//  ToggleFavoriteUseCase.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

struct ToggleFavoriteUseCase {
    private let repository: FavoritesRepository

    init(repository: FavoritesRepository) {
        self.repository = repository
    }

    func callAsFunction(
        station: Station,
        networkID: String,
        isFavorite: Bool,
        currentFavorites: [FavoriteStation]
    ) async throws -> [FavoriteStation] {
        var favorites = currentFavorites

        if let index = favorites.firstIndex(where: { $0.id == station.id }) {
            if isFavorite {
                favorites[index] = FavoriteStation(
                    station: station,
                    networkID: networkID,
                    savedAt: favorites[index].savedAt
                )
            } else {
                favorites.remove(at: index)
            }
        } else if isFavorite {
            favorites.append(FavoriteStation(station: station, networkID: networkID))
        }

        return try await repository.saveFavorites(favorites)
    }
}
