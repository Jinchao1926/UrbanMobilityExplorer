//
//  FavoritesCacheProvider.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

protocol FavoritesCacheProvider {
    func loadFavorites() async throws -> [FavoriteStation]

    func saveFavorites(_ favorites: [FavoriteStation]) async throws
}
