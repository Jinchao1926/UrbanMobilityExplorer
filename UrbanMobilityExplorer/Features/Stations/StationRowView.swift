//
//  StationRowView.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct StationRowView: View {
    let station: Station
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(station.name)
                    .font(.headline)

                Spacer()

                if isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .accessibilityLabel("Favorite")
                }
            }

            Text(station.neighborhood)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Label("\(station.availableBikes) bikes", systemImage: "bicycle")
                Label("\(station.openDocks) docks", systemImage: "parkingsign.circle")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
