//
//  LoadNetworksUseCase.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

struct LoadNetworksUseCase {
    private let repository: StationRepository

    init(repository: StationRepository) {
        self.repository = repository
    }

    func callAsFunction(onlyChina: Bool) async throws -> [Network] {
        try await repository.loadNetworks(onlyChina: onlyChina)
    }
}
