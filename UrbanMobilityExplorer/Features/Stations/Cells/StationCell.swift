//
//  StationCell.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct StationCell: View {
    let station: Station
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(station.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(station.neighborhood)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .layoutPriority(1)

                Spacer()

                favoriteIndicator
            }

            availabilityMetrics
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    private var availabilityMetrics: some View {
        HStack(spacing: 8) {
            availabilityBadge(
                "\(station.availableBikes)",
                label: "Bikes",
                systemImage: "bicycle",
                tint: .green
            )
            availabilityBadge(
                "\(station.openDocks)",
                label: "Docks",
                systemImage: "parkingsign.circle",
                tint: .blue
            )
        }
    }

    @ViewBuilder
    private var favoriteIndicator: some View {
        if isFavorite {
            Image(systemName: "star.fill")
                .imageScale(.small)
                .foregroundStyle(.yellow)
                .frame(width: 28, height: 28)
                .background(.yellow.opacity(0.14), in: Circle())
                .accessibilityLabel("Favorite")
        } else {
            Color.clear
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)
        }
    }

    private func availabilityBadge(
        _ value: String,
        label: String,
        systemImage: String,
        tint: Color
    ) -> some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .imageScale(.small)

            Text(value)
                .fontWeight(.semibold)

            Text(label)
                .foregroundStyle(.secondary)
        }
        .font(.caption)
        .foregroundStyle(tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(tint.opacity(0.12), in: Capsule())
        .lineLimit(1)
        .minimumScaleFactor(0.85)
        .accessibilityLabel("\(value) \(label.lowercased())")
    }
}
