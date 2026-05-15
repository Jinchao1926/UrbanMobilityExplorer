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
        networkName: String?,
        isFavorite: Bool,
        currentFavorites: [FavoriteStation]
    ) async throws -> [FavoriteStation] {
        var favorites = currentFavorites
        let favoriteID = FavoriteStation.id(stationID: station.id, networkID: networkID)

        if let index = favorites.firstIndex(where: { $0.id == favoriteID }) {
            if isFavorite {
                favorites[index] = FavoriteStation(
                    station: station,
                    networkID: networkID,
                    networkName: networkName,
                    savedAt: favorites[index].savedAt
                )
            } else {
                favorites.remove(at: index)
            }
        } else if isFavorite {
            favorites.append(
                FavoriteStation(
                    station: station,
                    networkID: networkID,
                    networkName: networkName
                )
            )
        }

        return try await repository.saveFavorites(favorites)
    }
}
