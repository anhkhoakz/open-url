//
//  OpenURLApp.swift
//  Open URL
//

import SwiftUI

@main
internal struct OpenURLApp: App {
    private enum Layout {
        static let windowWidth: CGFloat = 1_080
        static let windowHeight: CGFloat = 720
        static let settingsWidth: CGFloat = 420
        static let settingsPadding: CGFloat = 24
    }

    @AppStorage("selectedBrowserBundleIdentifier")
    private var selectedBrowserBundleIdentifier: String = ""

    @AppStorage("stripTrackingParameters")
    private var stripTrackingParameters: Bool = true

    @State private var workspace: URLWorkspace = URLWorkspace()

    internal var body: some Scene {
        WindowGroup("OpenURL", id: "main") {
            ContentView(
                workspace: workspace,
                selectedBrowserBundleIdentifier: $selectedBrowserBundleIdentifier,
                stripTrackingParameters: $stripTrackingParameters
            )
        }
        .defaultSize(width: Layout.windowWidth, height: Layout.windowHeight)
        .commands {
            WorkspaceCommands()
        }

        Settings {
            SettingsView(
                workspace: workspace,
                selectedBrowserBundleIdentifier: $selectedBrowserBundleIdentifier,
                stripTrackingParameters: $stripTrackingParameters
            )
            .frame(width: Layout.settingsWidth)
            .padding(Layout.settingsPadding)
        }

        MenuBarExtra("OpenURL", systemImage: "link.badge.plus") {
            MenuBarExtraView(
                workspace: workspace,
                selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier,
                stripTrackingParameters: stripTrackingParameters
            )
        }
    }
}
