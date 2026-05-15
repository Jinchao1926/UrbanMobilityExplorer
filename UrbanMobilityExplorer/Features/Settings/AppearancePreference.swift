//
//  AppearancePreference.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

enum AppearancePreference: String, CaseIterable, Identifiable {
    static let storageKey = "appearancePreference"
    static let defaultValue = AppearancePreference.system

    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
