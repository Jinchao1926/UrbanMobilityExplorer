//
//  FavoriteStation.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

import Foundation

/// The `FavoriteStation` structure
struct FavoriteStation: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let station: Station
    let networkID: String
    let savedAt: Date

    // MARK: - LifeCycle
    init(station: Station, networkID: String, savedAt: Date = Date()) {
        self.id = station.id
        self.station = station
        self.networkID = networkID
        self.savedAt = savedAt
    }
}
