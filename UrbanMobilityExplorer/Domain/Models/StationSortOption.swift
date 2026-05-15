//
//  StationSortOption.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import Foundation

enum StationSortOption: String, CaseIterable, Identifiable, Sendable {
    case mostBikes
    case mostDocks
    case name

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mostBikes:
            return "Most Bikes"
        case .mostDocks:
            return "Most Docks"
        case .name:
            return "Name"
        }
    }
}

extension [Station] {
    func sorted(using option: StationSortOption) -> [Station] {
        sorted(by: option.areInIncreasingOrder)
    }
}

private extension StationSortOption {
    func areInIncreasingOrder(_ lhs: Station, _ rhs: Station) -> Bool {
        switch self {
        case .mostBikes:
            if lhs.availableBikes != rhs.availableBikes {
                return lhs.availableBikes > rhs.availableBikes
            }
            return isOrderedByName(lhs, rhs)

        case .mostDocks:
            if lhs.openDocks != rhs.openDocks {
                return lhs.openDocks > rhs.openDocks
            }
            return isOrderedByName(lhs, rhs)

        case .name:
            return isOrderedByName(lhs, rhs)
        }
    }

    func isOrderedByName(_ lhs: Station, _ rhs: Station) -> Bool {
        let nameOrder = lhs.name.localizedCaseInsensitiveCompare(rhs.name)
        if nameOrder != .orderedSame {
            return nameOrder == .orderedAscending
        }
        return lhs.id.localizedCaseInsensitiveCompare(rhs.id) == .orderedAscending
    }
}
