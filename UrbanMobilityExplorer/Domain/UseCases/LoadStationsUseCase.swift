//
//  LoadStationsUseCase.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

nonisolated struct LoadStationsUseCase {
    private let repository: StationRepository

    init(repository: StationRepository) {
        self.repository = repository
    }

    func callAsFunction(for network: Network) async throws -> StationLoadResult {
        try await repository.loadStations(for: network)
    }
}
