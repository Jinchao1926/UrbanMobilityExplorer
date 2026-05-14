//
//  StationSortOption.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

enum StationSortOption: String, CaseIterable, Identifiable {
    case availability
    case name
    case neighborhood

    var id: String { rawValue }

    var title: String {
        switch self {
        case .availability:
            return "Availability"
        case .name:
            return "Name"
        case .neighborhood:
            return "Area"
        }
    }
}

extension [Station] {
    func sorted(using option: StationSortOption) -> [Station] {
        switch option {
        case .availability:
            return sorted { $0.availableBikes > $1.availableBikes }
        case .name:
            return sorted { $0.name < $1.name }
        case .neighborhood:
            return sorted { $0.neighborhood < $1.neighborhood }
        }
    }
}
