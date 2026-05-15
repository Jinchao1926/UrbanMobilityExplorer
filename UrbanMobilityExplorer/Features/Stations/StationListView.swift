//
//  StationListView.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct StationListView: View {
    @ObservedObject var viewModel: StationListViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel

    private var content: StationListContent? {
        switch viewModel.state {
        case .loaded(let content), .empty(let content):
            return content
        case .loading, .error:
            return nil
        }
    }

    // MARK: - UI
    var body: some View {
        List {
            // Network
            Section {
                NavigationLink {
                    NetworkSelectionView(viewModel: viewModel)
                } label: {
                    LabeledContent("Network") {
                        Text(viewModel.selectedNetwork?.displayName ?? "Select")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
            } header: {
                Text("City")
            }

            // Error message
            if let message = content?.message {
                Section {
                    Label(message, systemImage: statusSystemImage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            // Stations
            if !viewModel.visibleStations.isEmpty {
                Section {
                    ForEach(viewModel.visibleStations) { station in
                        NavigationLink {
                            StationDetailView(
                                station: station,
                                networkID: content?.selectedNetwork?.id ?? "",
                                networkName: content?.selectedNetwork?.displayName,
                                favoritesViewModel: favoritesViewModel
                            )
                        } label: {
                            StationCell(
                                station: station,
                                isFavorite: favoritesViewModel.isFavorite(
                                    stationID: station.id,
                                    networkID: content?.selectedNetwork?.id ?? ""
                                )
                            )
                        }
                        .accessibilityIdentifier("station-row-\(station.id)")
                    }
                } header: {
                    Text("Nearby availability")
                } footer: {
                    Text(
                        "Live availability from CityBikes v2. " +
                        "Offline sample data is shown if the network is unavailable."
                    )
                }
            }
        }
        .navigationTitle("Stations")
        .searchable(text: $viewModel.searchText, prompt: "Search stations")
        .refreshable {
            await viewModel.loadStations()
            await favoritesViewModel.loadFavorites()
        }
        .overlay {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading stations")
            case .error(let message):
                EmptyStateView(
                    title: "Unable to Load",
                    systemImage: "wifi.slash",
                    message: message
                )
            case .empty(let content):
                stationEmptyState(for: content)
            case .loaded:
                if viewModel.visibleStations.isEmpty {
                    EmptyStateView(
                        title: "No Results",
                        systemImage: "magnifyingglass",
                        message: "Try another search term or clear filters."
                    )
                } else {
                    EmptyView()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Sort by", selection: $viewModel.sortOption) {
                        ForEach(StationSortOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Sort")
            }
        }
        .task {
            await viewModel.loadStations()
            await favoritesViewModel.loadFavorites()
        }
    }

    private var statusSystemImage: String {
        guard let content else { return "info.circle" }
        if content.isRefreshing {
            return "arrow.clockwise"
        }

        switch content.source {
        case .live:
            return "checkmark.circle"
        case .cached:
            return "externaldrive"
        case .offline:
            return "wifi.slash"
        }
    }

    @ViewBuilder
    private func stationEmptyState(for content: StationListContent) -> some View {
        if viewModel.isFiltering {
            EmptyStateView(
                title: "No Results",
                systemImage: "magnifyingglass",
                message: "Try another search term or clear filters."
            )
        } else if content.networks.isEmpty {
            EmptyStateView(
                title: "No Networks",
                systemImage: "wifi.slash",
                message: "No CityBikes networks are available for the current filter."
            )
        } else {
            EmptyStateView(
                title: "No Stations",
                systemImage: "bicycle",
                message: "The selected network does not have station availability to show."
            )
        }
    }
}
