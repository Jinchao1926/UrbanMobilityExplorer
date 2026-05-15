//
//  DefaultStationRepository.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

struct DefaultStationRepository: StationRepository {
    private let remote: StationDataProvider
    private let cache: StationCacheProvider
    private let offline: StationDataProvider
    
    // MARK: - LifeCycle
    init(
        remote: StationDataProvider,
        cache: StationCacheProvider,
        offline: StationDataProvider = OfflineStationDataSource()
    ) {
        self.remote = remote
        self.cache = cache
        self.offline = offline
    }
    
    // MARK: - Public
    func loadNetworks(onlyChina: Bool) async throws -> [Network] {
        do {
            // Try remote
            let networks = try await remote.loadNetworks()
            try await cache.saveNetworks(networks)
            return filtered(networks, onlyChina: onlyChina)
        } catch {
            // Try cache
            let cachedNetworks = (try? await cache.loadNetworks()) ?? []
            if !cachedNetworks.isEmpty {
                return filtered(cachedNetworks, onlyChina: onlyChina)
            }
            
            // Try offline
            return filtered(try await offline.loadNetworks(), onlyChina: onlyChina)
        }
    }
    
    func loadStations(for network: Network) async throws -> StationLoadResult {
        do {
            // Try remote
            let stations = try await remote.loadStations(for: network)
            try await cache.saveStations(stations, for: network.id)
            return StationLoadResult(stations: stations, source: .live)
        } catch {
            // Try cached
            let cachedStations = (try? await cache.loadStations(for: network)) ?? []
            if !cachedStations.isEmpty {
                return StationLoadResult(stations: cachedStations, source: .cached)
            }
            
            // Try offline
            let offlineStations = (try? await offline.loadStations(for: network)) ?? []
            if !offlineStations.isEmpty {
                return StationLoadResult(stations: offlineStations, source: .offline)
            }
            
            throw error
        }
    }
}

// MARK: - Private
extension DefaultStationRepository {
    private func filtered(_ networks: [Network], onlyChina: Bool) -> [Network] {
        onlyChina ? networks.filter { $0.country == "CN" } : networks
    }
}
