//
//  FavoritesRepository.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

protocol FavoritesRepository {
    func loadFavorites() async throws -> [FavoriteStation]

    func isFavorite(stationID: String) async throws -> Bool

    func toggleFavorite(station: Station, networkID: String) async throws -> Bool
}
