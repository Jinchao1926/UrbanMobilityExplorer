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
    let networkName: String
    let savedAt: Date

    static func id(stationID: String, networkID: String) -> String {
        "\(networkID)::\(stationID)"
    }

    // MARK: - LifeCycle
    init(
        station: Station,
        networkID: String,
        networkName: String? = nil,
        savedAt: Date = Date()
    ) {
        self.id = Self.id(stationID: station.id, networkID: networkID)
        self.station = station
        self.networkID = networkID
        self.networkName = networkName?.nilIfBlank ?? networkID
        self.savedAt = savedAt
    }
}

extension FavoriteStation {
    enum CodingKeys: String, CodingKey {
        case id
        case station
        case networkID
        case networkName
        case savedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        station = try container.decode(Station.self, forKey: .station)
        networkID = try container.decode(String.self, forKey: .networkID)
        networkName = try container
            .decodeIfPresent(String.self, forKey: .networkName)?
            .nilIfBlank ?? networkID
        savedAt = try container.decode(Date.self, forKey: .savedAt)
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
