//
//  StationListView.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct StationListView: View {
    let stations: [Station]
    @Binding var favoriteStationIDs: Set<String>

    @State private var searchText = ""
    @State private var sortOption = StationSortOption.availability

    private var visibleStations: [Station] {
        stations
            .filter { station in
                searchText.isEmpty ||
                station.name.localizedCaseInsensitiveContains(searchText) ||
                station.neighborhood.localizedCaseInsensitiveContains(searchText)
            }
            .sorted(using: sortOption)
    }

    var body: some View {
        List {
            Section {
                ForEach(visibleStations) { station in
                    NavigationLink {
                        StationDetailView(station: station, favoriteStationIDs: $favoriteStationIDs)
                    } label: {
                        StationRowView(station: station, isFavorite: favoriteStationIDs.contains(station.id))
                    }
                    .accessibilityIdentifier("station-row-\(station.id)")
                }
            } header: {
                Text("Nearby availability")
            } footer: {
                Text("Sample station data keeps the UI reviewable before the live data layer is added.")
            }
        }
        .navigationTitle("Stations")
        .searchable(text: $searchText, prompt: "Search stations")
        .refreshable {
            // Data loading will be wired after the service layer is added.
        }
        .overlay {
            if visibleStations.isEmpty {
                EmptyStateView(
                    title: "No Stations",
                    systemImage: "magnifyingglass",
                    message: "Try another search term or clear filters."
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    // Filter controls will be connected with real station metadata later.
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(StationSortOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }

                Button {
                    // Refresh action will call the station repository later.
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
    }
}
