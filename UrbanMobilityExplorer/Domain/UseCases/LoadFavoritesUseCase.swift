//
//  LoadFavoritesUseCase.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

nonisolated struct LoadFavoritesUseCase {
    private let repository: FavoritesRepository

    init(repository: FavoritesRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> [FavoriteStation] {
        try await repository.loadFavorites()
    }
}
