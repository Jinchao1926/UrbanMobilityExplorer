//
//  StationDataSource.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

enum StationDataSource: String, Codable, Equatable, Sendable {
    case live
    case cached
    case offline

    var title: String {
        switch self {
        case .live:
            return "Live"
        case .cached:
            return "Cached"
        case .offline:
            return "Offline"
        }
    }
}

struct StationLoadResult: Sendable {
    let stations: [Station]
    let source: StationDataSource
}
