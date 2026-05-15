//
//  StationDetailView.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct StationDetailView: View {
    let station: Station
    let networkID: String
    let networkName: String?
    @ObservedObject var favoritesViewModel: FavoritesViewModel

    private var coordinateText: String {
        "\(formattedCoordinate(station.latitude)), \(formattedCoordinate(station.longitude))"
    }

    private var networkDisplayName: String {
        networkName?.nilIfBlank ?? networkID
    }

    private var isFavorite: Bool {
        favoritesViewModel.isFavorite(stationID: station.id, networkID: networkID)
    }

    // MARK: - UI
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(station.name)
                            .font(.title2.weight(.semibold))
                    }

                    Text(station.address)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Network") {
                StationDetailCell(
                    title: "Name",
                    value: networkDisplayName,
                    systemImage: "network"
                )
            }

            Section("Current status") {
                StationDetailCell(
                    title: "Available bikes",
                    value: "\(station.availableBikes)",
                    systemImage: "bicycle"
                )
                StationDetailCell(
                    title: "Open docks",
                    value: "\(station.openDocks)",
                    systemImage: "parkingsign.circle"
                )
                StationDetailCell(
                    title: "Last updated",
                    value: station.lastUpdated,
                    systemImage: "clock"
                )
            }

            Section("Location") {
                StationDetailCell(
                    title: "Address",
                    value: station.address,
                    systemImage: "mappin.and.ellipse"
                )
                StationDetailCell(
                    title: "Coordinates",
                    value: coordinateText,
                    systemImage: "location"
                )
            }
        }
        .navigationTitle("Station Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let shouldFavorite = !isFavorite
                    Task {
                        await favoritesViewModel.toggleFavorite(
                            station: station,
                            networkID: networkID,
                            networkName: networkDisplayName,
                            isFavorite: shouldFavorite
                        )
                    }
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(isFavorite ? "Remove Favorite" : "Add Favorite")
            }
        }
        .task {
            await favoritesViewModel.refreshFavoriteStatus()
        }
    }
}

// MARK: - Private
private extension StationDetailView {
    func formattedCoordinate(_ coordinate: Double) -> String {
        coordinate.formatted(.number.precision(.fractionLength(4)))
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
