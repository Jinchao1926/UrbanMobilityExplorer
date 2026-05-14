//
//  SettingsView.swift
//  UrbanMobilityExplorer
//
//  Created by Jinchao Lin on 2026/5/14.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("appearancePreference") private var appearancePreference = AppearancePreference.system.rawValue

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Color mode", selection: $appearancePreference) {
                    ForEach(AppearancePreference.allCases) { preference in
                        Text(preference.title).tag(preference.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Review readiness") {
                LabeledContent("Data mode", value: "Offline sample")
                LabeledContent("Minimum iOS", value: "16")
            }
        }
        .navigationTitle("Settings")
    }
}
