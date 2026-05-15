//
//  CityBikesV2StationService.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import Foundation

/// Provides CityBikes v2 station capacities.
struct CityBikesV2StationService: StationDataProvider {
    private let baseURL: URL
    private let httpClient: HTTPClient

    // MARK: - LifeCycle
    init(
        baseURL: URL = URL(string: "https://api.citybik.es/v2")!,
        httpClient: HTTPClient = URLSessionHTTPClient()
    ) {
        self.baseURL = baseURL
        self.httpClient = httpClient
    }

    // MARK: - Networks
    func loadNetworks() async throws -> [Network] {
        let url = baseURL.appending(path: "networks")
        let data = try await httpClient.data(from: url)

        return try CityBikesV2StationMapper.mapNetworks(from: data)
    }

    // MARK: - Network Stations
    func loadStations(for network: Network) async throws -> [Station] {
        let url = baseURL
            .appending(path: "networks")
            .appending(path: network.id)
        let data = try await httpClient.data(from: url)

        return try CityBikesV2StationMapper.mapStations(from: data)
    }
}
