//
//  StationRepository.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

protocol StationRepository {
    func loadNetworks(onlyChina: Bool) async throws -> [Network]

    func loadStations(for network: Network) async throws -> StationLoadResult
}
