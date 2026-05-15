//
//  FavoritesCacheStore.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

import Foundation

/// Persists favorite stations in the app's file container.
actor FavoritesCacheStore: FavoritesCacheProvider {
    private let fileURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    // MARK: - LifeCycle
    init(fileURL: URL? = nil) {
        let baseURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        self.fileURL = fileURL ?? baseURL.appending(path: "favorites.json")
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    // MARK: - Favorites
    func loadFavorites() async throws -> [FavoriteStation] {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([FavoriteStation].self, from: data)
    }

    func saveFavorites(_ favorites: [FavoriteStation]) async throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let data = try encoder.encode(favorites)
        try data.write(to: fileURL, options: [.atomic])
    }
}
