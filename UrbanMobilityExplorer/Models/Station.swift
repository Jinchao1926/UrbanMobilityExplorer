//
//  Station.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import Foundation

struct Station: Identifiable, Hashable {
    let id: String
    let name: String
    let neighborhood: String
    let availableBikes: Int
    let openDocks: Int
    let latitude: Double
    let longitude: Double
    let lastUpdated: String

    var availabilityLevel: AvailabilityLevel {
        switch availableBikes {
        case 8...:
            return .high
        case 3...:
            return .medium
        default:
            return .low
        }
    }

    static let sampleStations = [
        Station(
            id: "central-library",
            name: "Central Library",
            neighborhood: "Downtown",
            availableBikes: 12,
            openDocks: 6,
            latitude: 37.7793,
            longitude: -122.4159,
            lastUpdated: "Just now"
        ),
        Station(
            id: "market-street",
            name: "Market Street",
            neighborhood: "Civic Center",
            availableBikes: 4,
            openDocks: 14,
            latitude: 37.7810,
            longitude: -122.4117,
            lastUpdated: "4 min ago"
        ),
        Station(
            id: "ferry-building",
            name: "Ferry Building",
            neighborhood: "Embarcadero",
            availableBikes: 1,
            openDocks: 19,
            latitude: 37.7955,
            longitude: -122.3937,
            lastUpdated: "8 min ago"
        )
    ]
}
