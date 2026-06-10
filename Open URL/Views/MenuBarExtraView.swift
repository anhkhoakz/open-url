//
//  MenuBarExtraView.swift
//  Open URL
//

import SwiftUI

internal struct MenuBarExtraView: View {
    private enum Layout {
        static let spacingSmall: CGFloat = 10
        static let lineLimitMedium: Int = 3
        static let maxWidthMedium: CGFloat = 220
        static let paddingMedium: CGFloat = 12
    }

    @Bindable internal var workspace: URLWorkspace

    internal let selectedBrowserBundleIdentifier: String
    internal let stripTrackingParameters: Bool

    @Environment(\.openWindow)
    private var openWindow: OpenWindowAction

    internal var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacingSmall) {
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
                .lineLimit(Layout.lineLimitMedium)
                .frame(maxWidth: Layout.maxWidthMedium, alignment: .leading)
        }
        .padding(Layout.paddingMedium)
        .onAppear {
            workspace.configure(
                selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier,
                stripTrackingParameters: stripTrackingParameters
            )
        }
    }
}
