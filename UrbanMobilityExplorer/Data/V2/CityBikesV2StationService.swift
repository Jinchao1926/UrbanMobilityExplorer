//
//  CityBikesV2StationService.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import Foundation

/// Provides CityBikes v2 station capacities.
nonisolated struct CityBikesV2StationService: StationDataProvider {
    private static var defaultBaseURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.citybik.es"
        components.path = "/v2"

        guard let url = components.url else {
            preconditionFailure("Invalid CityBikes base URL configuration.")
        }

        return url
    }

    private let baseURL: URL
    private let httpClient: HTTPClient

    // MARK: - LifeCycle
    init(
        baseURL: URL = Self.defaultBaseURL,
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
