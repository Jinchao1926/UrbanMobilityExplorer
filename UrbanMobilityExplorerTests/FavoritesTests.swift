//
//  FavoritesTests.swift
//  UrbanMobilityExplorerTests
//
//  Created by Jinchao Lin on 2026/5/15.
//

import XCTest
@testable import UrbanMobilityExplorer

final class FavoritesTests: XCTestCase {
    /// Test add new favorite
    func testToggleFavoriteAddsNewFavorite() async throws {
        let station = TestData.station()
        let repository = DefaultFavoritesRepository(cache: InMemoryFavoritesCacheProvider())
        let sut = ToggleFavoriteUseCase(repository: repository)

        let favorites = try await sut(
            station: station,
            networkID: "network-1",
            networkName: "Network One",
            isFavorite: true,
            currentFavorites: []
        )

        XCTAssertEqual(favorites.map(\.id), ["network-1::station-1"])
        XCTAssertEqual(favorites.first?.station, station)
        XCTAssertEqual(favorites.first?.networkName, "Network One")
    }

    /// Test remove old favorite
    func testToggleFavoriteRemovesExistingFavorite() async throws {
        let station = TestData.station()
        let existingFavorite = FavoriteStation(
            station: station,
            networkID: "network-1",
            networkName: "Network One",
            savedAt: TestData.olderDate
        )
        let cache = InMemoryFavoritesCacheProvider(favorites: [existingFavorite])
        let repository = DefaultFavoritesRepository(cache: cache)
        let sut = ToggleFavoriteUseCase(repository: repository)

        let favorites = try await sut(
            station: station,
            networkID: "network-1",
            networkName: "Network One",
            isFavorite: false,
            currentFavorites: [existingFavorite]
        )

        XCTAssertTrue(favorites.isEmpty)
        let persistedFavorites = try await repository.loadFavorites()
        XCTAssertTrue(persistedFavorites.isEmpty)
    }

    /// Test update old favorite data while preserving saved date
    func testToggleFavoriteUpdatesExistingFavoriteAndPreservesSavedDate() async throws {
        let oldStation = TestData.station(name: "Old Name", availableBikes: 1)
        let updatedStation = TestData.station(name: "Updated Name", availableBikes: 8)
        let existingFavorite = FavoriteStation(
            station: oldStation,
            networkID: "network-1",
            networkName: "Network One",
            savedAt: TestData.olderDate
        )
        let cache = InMemoryFavoritesCacheProvider(favorites: [existingFavorite])
        let repository = DefaultFavoritesRepository(cache: cache)
        let sut = ToggleFavoriteUseCase(repository: repository)

        let favorites = try await sut(
            station: updatedStation,
            networkID: "network-1",
            networkName: "Renamed Network",
            isFavorite: true,
            currentFavorites: [existingFavorite]
        )

        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.station, updatedStation)
        XCTAssertEqual(favorites.first?.networkName, "Renamed Network")
        XCTAssertEqual(favorites.first?.savedAt, TestData.olderDate)
    }

    /// Test load persisted favorites ordered by newest first
    func testFavoritesRepositoryLoadsPersistedFavoritesNewestFirst() async throws {
        let fileURL = try temporaryFavoritesFileURL()
        let olderFavorite = FavoriteStation(
            station: TestData.station(id: "older-station"),
            networkID: "network-1",
            savedAt: TestData.olderDate
        )
        let newerFavorite = FavoriteStation(
            station: TestData.station(id: "newer-station"),
            networkID: "network-1",
            savedAt: TestData.newerDate
        )
        let firstRepository = DefaultFavoritesRepository(
            cache: FavoritesCacheStore(fileURL: fileURL)
        )
        let secondRepository = DefaultFavoritesRepository(
            cache: FavoritesCacheStore(fileURL: fileURL)
        )

        _ = try await firstRepository.saveFavorites([olderFavorite, newerFavorite])
        let loadedFavorites = try await secondRepository.loadFavorites()

        XCTAssertEqual(loadedFavorites.map(\.id), [newerFavorite.id, olderFavorite.id])
        XCTAssertEqual(loadedFavorites.first?.station.id, newerFavorite.station.id)
    }

    private func temporaryFavoritesFileURL() throws -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
            .appending(path: "UrbanMobilityExplorerTests")
            .appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directoryURL)
        }
        return directoryURL.appending(path: "favorites.json")
    }
}
