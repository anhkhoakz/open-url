//
//  SettingsView.swift
//  Open URL
//

import SwiftUI

struct SettingsView: View {
    @Bindable var workspace: URLWorkspace
    @Binding var selectedBrowserBundleIdentifier: String
    @Binding var stripTrackingParameters: Bool

    var body: some View {
        Form {
            Picker("Preferred Browser", selection: $selectedBrowserBundleIdentifier) {
                Text("Default Browser").tag("")

                ForEach(workspace.availableBrowsers) { browser in
                    Text(browser.isDefault ? "\(browser.name) (Default)" : browser.name)
                        .tag(browser.bundleIdentifier)
                }
            }

            Toggle("Remove common tracking parameters", isOn: $stripTrackingParameters)

            VStack(alignment: .leading, spacing: 6) {
                Text("OpenURL reads the clipboard only after an explicit action.")
                Text("Use the menu bar item for instant clipboard opening, or keep the main window open for paste-and-review.")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
        }
        .formStyle(.grouped)
        .onAppear {
            workspace.reloadBrowsers(selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier)
        }
    }
}
