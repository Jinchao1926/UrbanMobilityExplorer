//
//  FavoritesViewState.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

enum FavoritesViewState: Equatable {
    case loading
    case loaded([FavoriteStation])
    case empty
    case error(message: String)
}
