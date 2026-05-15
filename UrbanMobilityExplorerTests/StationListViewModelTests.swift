//
//  StationListViewModelTests.swift
//  UrbanMobilityExplorerTests
//
//  Created by Jinchao Lin on 2026/5/15.
//

import XCTest
@testable import UrbanMobilityExplorer

@MainActor
final class StationListViewModelTests: XCTestCase {
    /// Test load stations publishes loaded content
    func testLoadStationsPublishesLoadedContent() async {
        let network = TestData.network()
        let station = TestData.station(id: "station-live")
        let sut = makeSUT(
            networks: [network],
            stationResultsByNetworkID: [
                network.id: [.success(StationLoadResult(stations: [station], source: .live))]
            ]
        )

        await sut.loadStations()

        let content = try? XCTUnwrap(sut.state.loadedContent)
        XCTAssertEqual(content?.stations, [station])
        XCTAssertEqual(content?.networks, [network])
        XCTAssertEqual(content?.selectedNetwork, network)
        XCTAssertEqual(content?.source, .live)
        XCTAssertEqual(content?.isRefreshing, false)
        XCTAssertNil(content?.message)
    }

    /// Test load stations publishes empty content when networks are unavailable
    func testLoadStationsPublishesEmptyContentWhenNetworksAreUnavailable() async {
        let sut = makeSUT(networks: [])

        await sut.loadStations()

        let content = try? XCTUnwrap(sut.state.emptyContent)
        XCTAssertEqual(content?.stations, [])
        XCTAssertEqual(content?.networks, [])
        XCTAssertNil(content?.selectedNetwork)
        XCTAssertEqual(content?.source, .offline)
        XCTAssertEqual(content?.message, "No networks are available for the current filter.")
    }

    /// Test load stations publishes error on initial failure
    func testLoadStationsPublishesErrorOnInitialFailure() async {
        let repository = StubStationRepository(networkResults: [.failure(TestError.expected)])
        let sut = makeSUT(repository: repository)

        await sut.loadStations()

        XCTAssertEqual(
            sut.state,
            .error(message: "Unable to load station data. Pull to refresh when the network is available.")
        )
    }

    /// Test refresh keeps existing content while loading latest stations
    func testLoadStationsPublishesRefreshingContentDuringRefresh() async {
        let network = TestData.network()
        let initialStation = TestData.station(id: "initial-station")
        let refreshedStation = TestData.station(id: "refreshed-station")
        var stationLoadCount = 0
        var refreshContinuation: CheckedContinuation<StationLoadResult, Error>?
        let repository = StubStationRepository(networkResults: [.success([network])]) { _ in
            stationLoadCount += 1

            if stationLoadCount == 1 {
                return StationLoadResult(stations: [initialStation], source: .live)
            }

            return try await withCheckedThrowingContinuation { continuation in
                refreshContinuation = continuation
            }
        }
        let sut = makeSUT(repository: repository)

        await sut.loadStations()
        let refreshTask = Task {
            await sut.loadStations()
        }

        while stationLoadCount < 2 {
            await Task.yield()
        }

        let refreshingContent = try? XCTUnwrap(sut.state.loadedContent)
        XCTAssertEqual(refreshingContent?.stations, [initialStation])
        XCTAssertEqual(refreshingContent?.isRefreshing, true)

        refreshContinuation?.resume(
            returning: StationLoadResult(stations: [refreshedStation], source: .cached)
        )
        await refreshTask.value

        let refreshedContent = try? XCTUnwrap(sut.state.loadedContent)
        XCTAssertEqual(refreshedContent?.stations, [refreshedStation])
        XCTAssertEqual(refreshedContent?.source, .cached)
        XCTAssertEqual(refreshedContent?.isRefreshing, false)
        XCTAssertEqual(refreshedContent?.message, "Live data is unavailable. Showing cached station data.")
    }

    /// Test refresh failure keeps existing content
    func testLoadStationsKeepsExistingContentWhenRefreshFails() async {
        let network = TestData.network()
        let station = TestData.station()
        let repository = StubStationRepository(
            networkResults: [.success([network])],
            stationResultsByNetworkID: [
                network.id: [
                    .success(StationLoadResult(stations: [station], source: .live)),
                    .failure(TestError.expected)
                ]
            ]
        )
        let sut = makeSUT(repository: repository)

        await sut.loadStations()
        await sut.loadStations()

        let content = try? XCTUnwrap(sut.state.loadedContent)
        XCTAssertEqual(content?.stations, [station])
        XCTAssertEqual(content?.isRefreshing, false)
        XCTAssertEqual(content?.message, "Unable to refresh station data. Showing the last available result.")
    }

    /// Test selecting network resets station content before reload
    func testSelectNetworkResetsContentAndLoadsSelectedNetwork() async {
        let firstNetwork = TestData.network(id: "first-network")
        let secondNetwork = TestData.network(id: "second-network")
        let firstStation = TestData.station(id: "first-station")
        let secondStation = TestData.station(id: "second-station")
        let sut = makeSUT(
            networks: [firstNetwork, secondNetwork],
            stationResultsByNetworkID: [
                firstNetwork.id: [.success(StationLoadResult(stations: [firstStation], source: .live))],
                secondNetwork.id: [.success(StationLoadResult(stations: [secondStation], source: .live))]
            ]
        )

        await sut.loadStations()
        let didSelectNetwork = sut.selectNetwork(secondNetwork)

        XCTAssertTrue(didSelectNetwork)
        XCTAssertEqual(sut.state, .loading)
        XCTAssertEqual(sut.visibleStations, [])

        await sut.loadStations()

        let content = try? XCTUnwrap(sut.state.loadedContent)
        XCTAssertEqual(content?.selectedNetwork, secondNetwork)
        XCTAssertEqual(content?.stations, [secondStation])
    }

    /// Test search filters visible stations by name and address
    func testVisibleStationsFiltersBySearchText() async {
        let network = TestData.network()
        let alphaStation = TestData.station(id: "alpha", name: "Alpha", address: "Main Road")
        let betaStation = TestData.station(id: "beta", name: "Beta", address: "Dock Street")
        let sut = makeSUT(
            networks: [network],
            stationResultsByNetworkID: [
                network.id: [.success(StationLoadResult(stations: [alphaStation, betaStation], source: .live))]
            ]
        )

        await sut.loadStations()
        sut.searchText = " dock "

        XCTAssertTrue(sut.isFiltering)
        XCTAssertEqual(sut.visibleStations, [betaStation])
    }

    /// Test sort option orders visible stations
    func testVisibleStationsSortsBySelectedOption() async {
        let network = TestData.network()
        let alphaStation = TestData.station(id: "alpha", name: "Alpha", availableBikes: 5, openDocks: 8)
        let bravoStation = TestData.station(id: "bravo", name: "Bravo", availableBikes: 1, openDocks: 10)
        let charlieStation = TestData.station(id: "charlie", name: "Charlie", availableBikes: 5, openDocks: 2)
        let sut = makeSUT(
            networks: [network],
            stationResultsByNetworkID: [
                network.id: [
                    .success(
                        StationLoadResult(
                            stations: [bravoStation, charlieStation, alphaStation],
                            source: .live
                        )
                    )
                ]
            ]
        )

        await sut.loadStations()

        sut.sortOption = .mostBikes
        XCTAssertEqual(sut.visibleStations, [alphaStation, charlieStation, bravoStation])

        sut.sortOption = .mostDocks
        XCTAssertEqual(sut.visibleStations, [bravoStation, alphaStation, charlieStation])

        sut.sortOption = .name
        XCTAssertEqual(sut.visibleStations, [alphaStation, bravoStation, charlieStation])
    }
}

private extension StationListViewModelTests {
    func makeSUT(
        networks: [Network],
        stationResultsByNetworkID: [String: [Result<StationLoadResult, Error>]] = [:]
    ) -> StationListViewModel {
        makeSUT(
            repository: StubStationRepository(
                networkResults: [.success(networks)],
                stationResultsByNetworkID: stationResultsByNetworkID
            )
        )
    }

    func makeSUT(repository: StationRepository) -> StationListViewModel {
        StationListViewModel(
            loadNetworks: LoadNetworksUseCase(repository: repository),
            loadStations: LoadStationsUseCase(repository: repository)
        )
    }
}

private extension StationListViewState {
    var loadedContent: StationListContent? {
        switch self {
        case .loaded(let content):
            return content
        case .loading, .empty, .error:
            return nil
        }
    }

    var emptyContent: StationListContent? {
        switch self {
        case .empty(let content):
            return content
        case .loading, .loaded, .error:
            return nil
        }
    }
}
