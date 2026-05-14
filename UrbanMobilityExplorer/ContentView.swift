//
//  ContentView.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("appearancePreference") private var appearancePreference = AppearancePreference.system.rawValue
    @State private var favoriteStationIDs: Set<String> = ["central-library"]

    private let stations = Station.sampleStations

    var body: some View {
        TabView {
            NavigationStack {
                StationListView(stations: stations, favoriteStationIDs: $favoriteStationIDs)
            }
            .tabItem {
                Label("Stations", systemImage: "tram.fill")
            }

            NavigationStack {
                FavoritesView(stations: stations, favoriteStationIDs: $favoriteStationIDs)
            }
            .tabItem {
                Label("Favorites", systemImage: "star.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .preferredColorScheme(
            AppearancePreference(rawValue: appearancePreference)?.colorScheme
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
