//
//  StationListViewState.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

enum StationListViewState: Equatable {
    case loading
    case loaded(StationListContent)
    case empty(StationListContent)
    case error(message: String)
}

struct StationListContent: Equatable {
    let stations: [Station]
    let networks: [Network]
    let selectedNetwork: Network?
    let source: StationDataSource
    let isRefreshing: Bool
    let message: String?
}
