//
//  CityBikeNetwork.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import Foundation

/// The `Network` structure
nonisolated struct Network: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double

    var displayName: String {
        "\(city) - \(name)"
    }
}
