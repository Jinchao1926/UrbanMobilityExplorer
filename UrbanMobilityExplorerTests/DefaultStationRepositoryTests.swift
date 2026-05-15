//
//  DefaultStationRepositoryTests.swift
//  UrbanMobilityExplorerTests
//
//  Created by Jinchao Lin on 2026/5/15.
//

import XCTest
@testable import UrbanMobilityExplorer

final class DefaultStationRepositoryTests: XCTestCase {
    /// Test load network from remote
    func testLoadNetworksUsesRemoteDataWhenAvailable() async throws {
        let cnNetwork = TestData.network(id: "cn-network", country: "CN")
        let usNetwork = TestData.network(id: "us-network", country: "US")
        let cache = InMemoryStationCacheProvider()
        let sut = DefaultStationRepository(
            remote: StubStationDataProvider(networksResult: .success([usNetwork, cnNetwork])),
            cache: cache,
            offline: StubStationDataProvider()
        )

        let networks = try await sut.loadNetworks(onlyChina: true)

        XCTAssertEqual(networks, [cnNetwork])
        XCTAssertEqual(cache.savedNetworks(), [usNetwork, cnNetwork])
    }

    /// Test load network from cache
    func testLoadNetworksFallsBackToCachedDataWhenRemoteFails() async throws {
        let cachedCNNetwork = TestData.network(id: "cached-cn-network", country: "CN")
        let cachedUSNetwork = TestData.network(id: "cached-us-network", country: "US")
        let cache = InMemoryStationCacheProvider(networks: [cachedUSNetwork, cachedCNNetwork])
        let sut = DefaultStationRepository(
            remote: StubStationDataProvider(networksResult: .failure(TestError.expected)),
            cache: cache,
            offline: StubStationDataProvider()
        )

        let networks = try await sut.loadNetworks(onlyChina: true)

        XCTAssertEqual(networks, [cachedCNNetwork])
    }

    /// Test load network from offline
    func testLoadNetworksFallsBackToOfflineDataWhenRemoteFailsAndCacheIsEmpty() async throws {
        let offlineNetwork = TestData.network(id: "offline-network")
        let sut = DefaultStationRepository(
            remote: StubStationDataProvider(networksResult: .failure(TestError.expected)),
            cache: InMemoryStationCacheProvider(),
            offline: StubStationDataProvider(networksResult: .success([offlineNetwork]))
        )

        let networks = try await sut.loadNetworks(onlyChina: true)

        XCTAssertEqual(networks, [offlineNetwork])
    }

    /// Test load station from remote
    func testLoadStationsUsesRemoteDataWhenAvailable() async throws {
        let network = TestData.network()
        let liveStation = TestData.station(id: "live-station")
        let cache = InMemoryStationCacheProvider()
        let sut = DefaultStationRepository(
            remote: StubStationDataProvider(stationsResult: .success([liveStation])),
            cache: cache,
            offline: StubStationDataProvider()
        )

        let result = try await sut.loadStations(for: network)

        XCTAssertEqual(result.source, .live)
        XCTAssertEqual(result.stations, [liveStation])
        XCTAssertEqual(cache.savedStations(for: network.id), [liveStation])
    }

    /// Test load station from cache
    func testLoadStationsFallsBackToCachedDataWhenRemoteFails() async throws {
        let network = TestData.network()
        let cachedStation = TestData.station(id: "cached-station")
        let cache = InMemoryStationCacheProvider(stationsByNetworkID: [network.id: [cachedStation]])
        let sut = DefaultStationRepository(
            remote: StubStationDataProvider(stationsResult: .failure(TestError.expected)),
            cache: cache,
            offline: StubStationDataProvider()
        )

        let result = try await sut.loadStations(for: network)

        XCTAssertEqual(result.source, .cached)
        XCTAssertEqual(result.stations, [cachedStation])
    }

    /// Test load station from offline
    func testLoadStationsFallsBackToOfflineDataWhenRemoteFailsAndCacheIsEmpty() async throws {
        let network = TestData.network()
        let offlineStation = TestData.station(id: "offline-station")
        let sut = DefaultStationRepository(
            remote: StubStationDataProvider(stationsResult: .failure(TestError.expected)),
            cache: InMemoryStationCacheProvider(),
            offline: StubStationDataProvider(stationsResult: .success([offlineStation]))
        )

        let result = try await sut.loadStations(for: network)

        XCTAssertEqual(result.source, .offline)
        XCTAssertEqual(result.stations, [offlineStation])
    }

    /// Test load station failure when all sources are unavailable
    func testLoadStationsThrowsWhenAllSourcesAreUnavailable() async {
        let network = TestData.network()
        let sut = DefaultStationRepository(
            remote: StubStationDataProvider(stationsResult: .failure(TestError.expected)),
            cache: InMemoryStationCacheProvider(),
            offline: StubStationDataProvider(stationsResult: .success([]))
        )

        do {
            _ = try await sut.loadStations(for: network)
            XCTFail("Expected loadStations to throw.")
        } catch {
            XCTAssertTrue(error is TestError)
        }
    }
}
