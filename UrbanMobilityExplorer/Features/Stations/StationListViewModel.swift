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
    
    private let loadNetworksUseCase: LoadNetworksUseCase
    private let loadStationsUseCase: LoadStationsUseCase

    private var stations: [Station] = []
    private var source: StationDataSource = .offline
    private var message: String?
    
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
    func loadStations() async {
        let keepsExistingContent = currentContent != nil

        if keepsExistingContent {
            publish(isRefreshing: true)
        } else {
            state = .loading
        }
        
        do {
            try await refreshNetworks(onlyChina: showsOnlyChinaNetworks)
            
            guard let selectedNetwork else {
                stations = []
                source = .offline
                message = networks.isEmpty ? "No networks are available for the current filter." : nil
                publish(isRefreshing: false)
                return
            }
            
            let result = try await loadStationsUseCase(for: selectedNetwork)
            stations = result.stations
            source = result.source
            message = sourceMessage(for: result.source)
            publish(isRefreshing: false)
        } catch {
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
        stations = []
        source = .offline
        message = nil
        state = .loading
    }

    func refreshNetworks(onlyChina: Bool) async throws {
        let fetchedNetworks = try await loadNetworksUseCase(onlyChina: onlyChina)
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
