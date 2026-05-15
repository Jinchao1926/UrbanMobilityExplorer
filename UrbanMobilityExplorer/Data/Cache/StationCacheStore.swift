//
//  StationCacheStore.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

import Foundation

/// Persists station and network snapshots in the app's file container.
actor StationCacheStore: StationCacheProvider {
    private let directoryURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    // MARK: - LifeCycle
    init(directoryURL: URL? = nil) {
        let baseURL = directoryURL ?? FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        self.directoryURL = baseURL.appending(path: "StationCache", directoryHint: .isDirectory)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
}

// MARK: - Networks
extension StationCacheStore {
    func saveNetworks(_ networks: [Network]) async throws {
        try ensureDirectoryExists()
        let data = try encoder.encode(networks)
        try data.write(to: networksURL, options: [.atomic])
    }

    func loadNetworks() async throws -> [Network] {
        guard FileManager.default.fileExists(atPath: networksURL.path()) else {
            return []
        }

        let data = try Data(contentsOf: networksURL)
        return try decoder.decode([Network].self, from: data)
    }
}

// MARK: - Stations
extension StationCacheStore {
    func saveStations(_ stations: [Station], for networkID: String) async throws {
        try ensureDirectoryExists()
        let data = try encoder.encode(stations)
        try data.write(to: stationsURL(for: networkID), options: [.atomic])
    }

    func loadStations(for network: Network) async throws -> [Station] {
        let url = stationsURL(for: network.id)
        guard FileManager.default.fileExists(atPath: url.path()) else {
            return []
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode([Station].self, from: data)
    }
}

// MARK: - Private
extension StationCacheStore {
    private var networksURL: URL {
        directoryURL.appending(path: "networks.json")
    }

    private func stationsURL(for networkID: String) -> URL {
        let safeID = networkID.replacingOccurrences(of: "/", with: "-")
        return directoryURL.appending(path: "\(safeID)-stations.json")
    }

    private func ensureDirectoryExists() throws {
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
    }
}
