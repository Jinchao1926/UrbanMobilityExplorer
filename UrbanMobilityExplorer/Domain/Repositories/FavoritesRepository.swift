//
//  FavoritesRepository.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

nonisolated protocol FavoritesRepository {
    func loadFavorites() async throws -> [FavoriteStation]

    func isFavorite(stationID: String, networkID: String) async throws -> Bool

    func saveFavorites(_ favorites: [FavoriteStation]) async throws -> [FavoriteStation]
}
