//
//  StationListViewModel.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import Combine
import Foundation

@MainActor
final class StationListViewModel: ObservableObject {
    @Published private(set) var state: StationListViewState = .loading
    @Published private(set) var networks: [Network] = []
    @Published private(set) var selectedNetwork: Network?
    @Published var showsOnlyChinaNetworks = true
    @Published var searchText = ""
    @Published var sortOption = StationSortOption.mostBikes

    private let loadNetworksUseCase: LoadNetworksUseCase
    private let loadStationsUseCase: LoadStationsUseCase

    private var stations: [Station] = []
    private var source: StationDataSource = .offline
    private var message: String?
    /// Request token
    private var loadGeneration = 0

    // MARK: - LifeCycle
    init(
        loadNetworks: LoadNetworksUseCase,
        loadStations: LoadStationsUseCase
    ) {
        self.loadNetworksUseCase = loadNetworks
        self.loadStationsUseCase = loadStations
    }
}

// MARK: - Stations
extension StationListViewModel {
    var visibleStations: [Station] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return stations
            .filter { station in
                query.isEmpty ||
                station.name.localizedCaseInsensitiveContains(query) ||
                station.address.localizedCaseInsensitiveContains(query)
            }
            .sorted(using: sortOption)
    }

    var isFiltering: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func loadStations() async {
        loadGeneration += 1
        let requestID = loadGeneration
        let keepsExistingContent = currentContent != nil

        if keepsExistingContent {
            publish(isRefreshing: true)
        } else {
            state = .loading
        }

        do {
            let fetchedNetworks = try await loadNetworksUseCase(onlyChina: showsOnlyChinaNetworks)
            guard isCurrentLoad(requestID) else { return }
            applyNetworks(fetchedNetworks)

            guard let selectedNetwork else {
                stations = []
                source = .offline
                message = networks.isEmpty ? "No networks are available for the current filter." : nil
                publish(isRefreshing: false)
                return
            }

            let result = try await loadStationsUseCase(for: selectedNetwork)
            guard isCurrentLoad(requestID) else { return }

            stations = result.stations
            source = result.source
            message = sourceMessage(for: result.source)
            publish(isRefreshing: false)
        } catch is CancellationError {
            return
        } catch {
            guard isCurrentLoad(requestID) else { return }

            let failureMessage = "Unable to refresh station data. Showing the last available result."

            if keepsExistingContent {
                message = failureMessage
                publish(isRefreshing: false)
            } else {
                state = .error(message: "Unable to load station data. Pull to refresh when the network is available.")
            }
        }
    }
}

// MARK: - Network
extension StationListViewModel {
    @discardableResult
    func selectNetwork(_ network: Network) -> Bool {
        guard network.id != selectedNetwork?.id else { return false }

        selectedNetwork = network
        resetStations()
        return true
    }

    func setShowsOnlyChinaNetworks(_ newValue: Bool) async {
        guard newValue != showsOnlyChinaNetworks else { return }

        showsOnlyChinaNetworks = newValue
        resetStations()
        await loadStations()
    }
}

// MARK: - Private
private extension StationListViewModel {
    var currentContent: StationListContent? {
        switch state {
        case .loaded(let content), .empty(let content):
            return content
        case .loading, .error:
            return nil
        }
    }

    func resetStations() {
        loadGeneration += 1
        stations = []
        source = .offline
        message = nil
        state = .loading
    }

    /// Request token used to identify the latest network request.
    /// Ensures old request responses do not overwrite new network or refreshed results.
    func isCurrentLoad(_ requestID: Int) -> Bool {
        requestID == loadGeneration && !Task.isCancelled
    }

    func applyNetworks(_ fetchedNetworks: [Network]) {
        networks = fetchedNetworks

        guard !fetchedNetworks.isEmpty else {
            selectedNetwork = nil
            return
        }

        if let selectedNetwork,
           fetchedNetworks.contains(where: { $0.id == selectedNetwork.id }) {
            return
        }

        selectedNetwork = fetchedNetworks.first
    }

    func sourceMessage(for source: StationDataSource) -> String? {
        switch source {
        case .live:
            return nil
        case .cached:
            return "Live data is unavailable. Showing cached station data."
        case .offline:
            return "Live data is unavailable. Showing offline sample data."
        }
    }

    func publish(isRefreshing: Bool) {
        let content = StationListContent(
            stations: stations,
            networks: networks,
            selectedNetwork: selectedNetwork,
            source: source,
            isRefreshing: isRefreshing,
            message: message
        )
        state = stations.isEmpty ? .empty(content) : .loaded(content)
    }
}
