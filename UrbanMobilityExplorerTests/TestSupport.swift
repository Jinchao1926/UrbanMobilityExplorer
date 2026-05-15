//
//  TestSupport.swift
//  UrbanMobilityExplorerTests
//
//  Created by Jinchao Lin on 2026/5/15.
//

import Foundation
@testable import UrbanMobilityExplorer

final class InMemoryStationCacheProvider: StationCacheProvider {
    private var networks: [Network]
    private var stationsByNetworkID: [String: [Station]]
    private var lastSavedNetworks: [Network]?
    private var lastSavedStationsByNetworkID: [String: [Station]] = [:]

    init(
        networks: [Network] = [],
        stationsByNetworkID: [String: [Station]] = [:]
    ) {
        self.networks = networks
        self.stationsByNetworkID = stationsByNetworkID
    }

    func loadNetworks() async throws -> [Network] {
        networks
    }

    func loadStations(for network: Network) async throws -> [Station] {
        stationsByNetworkID[network.id] ?? []
    }

    func saveNetworks(_ networks: [Network]) async throws {
        self.networks = networks
        lastSavedNetworks = networks
    }

    func saveStations(_ stations: [Station], for networkID: String) async throws {
        stationsByNetworkID[networkID] = stations
        lastSavedStationsByNetworkID[networkID] = stations
    }

    func savedNetworks() -> [Network]? {
        lastSavedNetworks
    }

    func savedStations(for networkID: String) -> [Station]? {
        lastSavedStationsByNetworkID[networkID]
    }
}

final class InMemoryFavoritesCacheProvider: FavoritesCacheProvider {
    private var favorites: [FavoriteStation]

    init(favorites: [FavoriteStation] = []) {
        self.favorites = favorites
    }

    func loadFavorites() async throws -> [FavoriteStation] {
        favorites
    }

    func saveFavorites(_ favorites: [FavoriteStation]) async throws {
        self.favorites = favorites
    }
}

struct StubStationDataProvider: StationDataProvider {
    var networksResult: Result<[Network], Error> = .success([])
    var stationsResult: Result<[Station], Error> = .success([])

    func loadNetworks() async throws -> [Network] {
        try networksResult.get()
    }

    func loadStations(for network: Network) async throws -> [Station] {
        try stationsResult.get()
    }
}

final class StubStationRepository: StationRepository {
    var networkResults: [Result<[Network], Error>]
    var stationResultsByNetworkID: [String: [Result<StationLoadResult, Error>]]
    var loadStationsHandler: ((Network) async throws -> StationLoadResult)?

    init(
        networkResults: [Result<[Network], Error>] = [.success([])],
        stationResultsByNetworkID: [String: [Result<StationLoadResult, Error>]] = [:],
        loadStationsHandler: ((Network) async throws -> StationLoadResult)? = nil
    ) {
        self.networkResults = networkResults
        self.stationResultsByNetworkID = stationResultsByNetworkID
        self.loadStationsHandler = loadStationsHandler
    }

    func loadNetworks(onlyChina: Bool) async throws -> [Network] {
        try nextNetworkResult().get()
    }

    func loadStations(for network: Network) async throws -> StationLoadResult {
        if let loadStationsHandler {
            return try await loadStationsHandler(network)
        }

        return try nextStationResult(for: network.id).get()
    }

    private func nextNetworkResult() -> Result<[Network], Error> {
        guard networkResults.count > 1 else {
            return networkResults.first ?? .success([])
        }

        return networkResults.removeFirst()
    }

    private func nextStationResult(for networkID: String) -> Result<StationLoadResult, Error> {
        var results = stationResultsByNetworkID[networkID] ?? [.success(StationLoadResult(stations: [], source: .live))]
        let result = results.count > 1 ? results.removeFirst() : results[0]
        stationResultsByNetworkID[networkID] = results
        return result
    }
}

enum TestData {
    static let olderDate = Date(timeIntervalSince1970: 1_700_000_000)
    static let newerDate = Date(timeIntervalSince1970: 1_800_000_000)

    static func network(
        id: String = "network-1",
        name: String = "Bike Network",
        city: String = "Shanghai",
        country: String = "CN"
    ) -> Network {
        Network(
            id: id,
            name: name,
            city: city,
            country: country,
            latitude: 31.2304,
            longitude: 121.4737
        )
    }

    static func station(
        id: String = "station-1",
        name: String = "People Square",
        address: String = "People Square",
        availableBikes: Int = 4,
        openDocks: Int = 6
    ) -> Station {
        Station(
            id: id,
            name: name,
            address: address,
            availableBikes: availableBikes,
            openDocks: openDocks,
            latitude: 31.2304,
            longitude: 121.4737,
            lastUpdated: "2026-05-15T08:00:00Z"
        )
    }
}

enum TestError: Error {
    case expected
}
