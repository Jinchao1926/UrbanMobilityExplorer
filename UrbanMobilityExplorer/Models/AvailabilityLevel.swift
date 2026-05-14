//
//  AvailabilityLevel.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

enum AvailabilityLevel {
    case high
    case medium
    case low

    var title: String {
        switch self {
        case .high:
            return "High"
        case .medium:
            return "Medium"
        case .low:
            return "Low"
        }
    }

    var foregroundStyle: Color {
        switch self {
        case .high:
            return .green
        case .medium:
            return .orange
        case .low:
            return .red
        }
    }

    var backgroundStyle: Color {
        foregroundStyle.opacity(0.12)
    }
}
