//
//  NetworkSelectionView.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/15.
//

import SwiftUI

struct NetworkSelectionView: View {
    @ObservedObject var viewModel: StationListViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var visibleNetworks: [Network] {
        viewModel.networks.filter { network in
            searchText.isEmpty ||
            network.displayName.localizedCaseInsensitiveContains(searchText) ||
            network.country.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var chinaOnlyBinding: Binding<Bool> {
        Binding(
            get: { viewModel.showsOnlyChinaNetworks },
            set: { newValue in
                Task {
                    await viewModel.setShowsOnlyChinaNetworks(newValue)
                }
            }
        )
    }

    // MARK: - UI
    var body: some View {
        List {
            Section {
                Toggle("China networks only", isOn: chinaOnlyBinding)
            } footer: {
                Text("Turn this off to browse every CityBikes network.")
            }

            Section("Networks") {
                ForEach(visibleNetworks) { network in
                    Button {
                        let shouldReload = viewModel.selectNetwork(network)
                        dismiss()

                        // Reload stations when network changed
                        guard shouldReload else { return }
                        Task {
                            await viewModel.loadStations()
                        }
                    } label: {
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(network.displayName)
                                    .foregroundStyle(.primary)
                                Text(network.country)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if network.id == viewModel.selectedNetwork?.id {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .accessibilityIdentifier("network-row-\(network.id)")
                }
            }
        }
        .navigationTitle("Networks")
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search networks"
        )
    }
}
