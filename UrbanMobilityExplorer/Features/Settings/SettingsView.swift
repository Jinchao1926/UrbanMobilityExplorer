//
//  SettingsView.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppearancePreference.storageKey)
    private var appearancePreference = AppearancePreference.defaultValue

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String

        switch (version, build) {
        case let (version?, build?) where !version.isEmpty && !build.isEmpty:
            return "\(version) (\(build))"
        case let (version?, _) where !version.isEmpty:
            return version
        case let (_, build?) where !build.isEmpty:
            return build
        default:
            return "Unknown"
        }
    }

    // MARK: - UI
    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Color mode", selection: $appearancePreference) {
                    ForEach(AppearancePreference.allCases) { preference in
                        Text(preference.title).tag(preference)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Review readiness") {
                LabeledContent("Data loading", value: "Live / Cache / Offline")
                LabeledContent("Minimum iOS", value: "16")
            }

            Section("About") {
                LabeledContent("Version", value: versionText)
            }
        }
        .navigationTitle("Settings")
    }
}
