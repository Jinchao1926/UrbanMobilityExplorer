//
//  Station.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import Foundation

/// The `Station` structure
struct Station: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let address: String
    let availableBikes: Int
    let openDocks: Int
    let latitude: Double
    let longitude: Double
    let lastUpdated: String
}
