//
//  ContentView.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(AppearancePreference.storageKey)
    private var appearancePreference = AppearancePreference.defaultValue

    @StateObject private var stationListViewModel: StationListViewModel
    @StateObject private var favoritesViewModel: FavoritesViewModel

    init(container: AppContainer = AppContainer()) {
        _stationListViewModel = StateObject(wrappedValue: container.makeStationListViewModel())
        _favoritesViewModel = StateObject(wrappedValue: container.makeFavoritesViewModel())
    }

    var body: some View {
        TabView {
            // Stations
            NavigationStack {
                StationListView(
                    viewModel: stationListViewModel,
                    favoritesViewModel: favoritesViewModel
                )
            }
            .tabItem {
                Label("Stations", systemImage: "tram.fill")
            }

            // Favorites
            NavigationStack {
                FavoritesView(viewModel: favoritesViewModel)
            }
            .tabItem {
                Label("Favorites", systemImage: "star.fill")
            }

            // Settings
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .preferredColorScheme(appearancePreference.colorScheme)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
