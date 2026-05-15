//
//  IsFavoriteStationUseCase.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

struct IsFavoriteStationUseCase {
    private let repository: FavoritesRepository

    init(repository: FavoritesRepository) {
        self.repository = repository
    }

    func callAsFunction(stationID: String) async throws -> Bool {
        try await repository.isFavorite(stationID: stationID)
    }
}
