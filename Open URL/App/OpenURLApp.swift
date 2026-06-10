//
//  OpenURLApp.swift
//  Open URL
//

import SwiftUI

@main
struct OpenURLApp: App {
    @AppStorage("selectedBrowserBundleIdentifier")
    private var selectedBrowserBundleIdentifier = ""

    @AppStorage("stripTrackingParameters")
    private var stripTrackingParameters = true

    @State
    private var workspace = URLWorkspace()

    var body: some Scene {
        WindowGroup("OpenURL", id: "main") {
            ContentView(
                workspace: workspace,
                selectedBrowserBundleIdentifier: $selectedBrowserBundleIdentifier,
                stripTrackingParameters: $stripTrackingParameters
            )
        }
        .defaultSize(width: 1_080, height: 720)
        .commands {
            WorkspaceCommands()
        }

        Settings {
            SettingsView(
                workspace: workspace,
                selectedBrowserBundleIdentifier: $selectedBrowserBundleIdentifier,
                stripTrackingParameters: $stripTrackingParameters
            )
            .frame(width: 420)
            .padding(24)
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
