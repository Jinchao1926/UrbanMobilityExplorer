//
//  OfflineStationDataSource.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

import Foundation

nonisolated struct OfflineStationDataSource: StationDataProvider {
    private let bundle: Bundle
    private let decoder = JSONDecoder()

    // MARK: - LifeCycle
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func loadNetworks() async throws -> [Network] {
        try load([Network].self, resource: "OfflineNetworks")
    }

    func loadStations(for network: Network) async throws -> [Station] {
        let stationsByNetwork = try load([String: [Station]].self, resource: "OfflineStations")
        return stationsByNetwork[network.id] ?? []
    }
}

// MARK: - Private
extension OfflineStationDataSource {
    nonisolated private func load<T: Decodable>(_ type: T.Type, resource: String) throws -> T {
        guard let url = bundle.url(forResource: resource, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode(type, from: data)
    }
}
