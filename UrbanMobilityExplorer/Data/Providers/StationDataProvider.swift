//
//  StationDataProvider.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

nonisolated protocol StationDataProvider {
    func loadNetworks() async throws -> [Network]

    func loadStations(for network: Network) async throws -> [Station]
}

nonisolated protocol StationCacheProvider: StationDataProvider {
    func saveNetworks(_ networks: [Network]) async throws

    func saveStations(_ stations: [Station], for networkID: String) async throws
}
