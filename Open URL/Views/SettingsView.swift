//
//  SettingsView.swift
//  Open URL
//

import SwiftUI

internal struct SettingsView: View {
    private enum Layout {
        static let spacingSmall: CGFloat = 6
        static let spacingMedium: CGFloat = 8
    }

    @Bindable internal var workspace: URLWorkspace
    @Binding internal var selectedBrowserBundleIdentifier: String
    @Binding internal var stripTrackingParameters: Bool

    internal var body: some View {
        Form {
            Picker("Preferred Browser", selection: $selectedBrowserBundleIdentifier) {
                Text("Default Browser").tag("")

                ForEach(workspace.availableBrowsers) { browser in
                    Text(browser.isDefault ? "\(browser.name) (Default)" : browser.name)
                        .tag(browser.bundleIdentifier)
                }
            }

            Toggle("Remove common tracking parameters", isOn: $stripTrackingParameters)

            VStack(alignment: .leading, spacing: Layout.spacingSmall) {
                Text("OpenURL reads the clipboard only after an explicit action.")
                Text(
                    "Use the menu bar item for instant clipboard opening, "
                        + "or keep the main window open for paste-and-review."
                )
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.top, Layout.spacingMedium)
        }
        .formStyle(.grouped)
        .onAppear {
            workspace.reloadBrowsers(
                selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier, force: false
            )
        }
    }
}
