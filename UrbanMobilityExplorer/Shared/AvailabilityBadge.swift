//
//  AvailabilityBadge.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct AvailabilityBadge: View {
    let level: AvailabilityLevel

    var body: some View {
        Text(level.title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(level.foregroundStyle)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(level.backgroundStyle, in: Capsule())
    }
}
