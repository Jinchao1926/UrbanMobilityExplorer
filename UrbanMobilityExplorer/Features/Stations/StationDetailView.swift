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
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    
    private var coordinateText: String {
        "\(formattedCoordinate(station.latitude)), \(formattedCoordinate(station.longitude))"
    }
    
    private var isFavorite: Bool {
        favoritesViewModel.isFavorite(stationID: station.id)
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
            await favoritesViewModel.refreshFavoriteStatus(for: station.id)
        }
    }
}

// MARK: - Private
private extension StationDetailView {
    func formattedCoordinate(_ coordinate: Double) -> String {
        coordinate.formatted(.number.precision(.fractionLength(4)))
    }
}
