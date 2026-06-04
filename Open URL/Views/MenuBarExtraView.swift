//
//  MenuBarExtraView.swift
//  Open URL
//

import SwiftUI

struct MenuBarExtraView: View {
    @Bindable var workspace: URLWorkspace

    let selectedBrowserBundleIdentifier: String
    let stripTrackingParameters: Bool

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button("Open URLs From Clipboard") {
                workspace.openClipboardURLs(
                    selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier,
                    stripTrackingParameters: stripTrackingParameters
                )
            }

            Button("Show Main Window") {
                openWindow(id: "main")
            }

            SettingsLink {
                Text("Settings")
            }

            Divider()

            Text(workspace.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .frame(maxWidth: 220, alignment: .leading)
        }
        .padding(12)
        .onAppear {
            workspace.configure(
                selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier,
                stripTrackingParameters: stripTrackingParameters
            )
        }
    }
}
