//
//  SelectionInspectorView.swift
//  Open URL
//

import SwiftUI

internal struct SelectionInspectorView: View {
    private enum Layout {
        static let spacingLarge: CGFloat = 18
        static let spacingMedium: CGFloat = 12
        static let spacingSmall: CGFloat = 8
        static let minWidthInspector: CGFloat = 260
    }

    @Bindable internal var workspace: URLWorkspace
    @Binding internal var selectedBrowserBundleIdentifier: String
    @Binding internal var stripTrackingParameters: Bool

    internal var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.spacingLarge) {
                openSection
                selectionSection
                shortcutsSection
            }
            .padding(.vertical, Layout.spacingSmall)
        }
        .frame(minWidth: Layout.minWidthInspector)
    }

    private var openSection: some View {
        GroupBox("Open") {
            VStack(alignment: .leading, spacing: Layout.spacingMedium) {
                Picker("Browser", selection: $selectedBrowserBundleIdentifier) {
                    Text("Default Browser").tag("")

                    ForEach(workspace.availableBrowsers) { browser in
                        Text(browser.isDefault ? "\(browser.name) (Default)" : browser.name)
                            .tag(browser.bundleIdentifier)
                    }
                }
                .pickerStyle(.menu)

                Toggle("Remove common tracking parameters", isOn: $stripTrackingParameters)
            }
        }
    }

    private var selectionSection: some View {
        GroupBox("Selection") {
            VStack(alignment: .leading, spacing: Layout.spacingSmall) {
                LabeledContent("Detected", value: "\(workspace.extractedURLs.count)")
                LabeledContent("Selected", value: "\(workspace.selectedURLs.count)")

                if let previewURL = workspace.previewURL {
                    Divider()
                    Text(previewURL.hostDisplay)
                        .font(.headline)

                    Text(previewURL.fullDisplay)
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                } else {
                    Text("Select a URL to preview it here.")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var shortcutsSection: some View {
        GroupBox("Shortcuts") {
            VStack(alignment: .leading, spacing: Layout.spacingSmall) {
                Text("Cmd-Shift-L loads clipboard text.")
                Text("Cmd-Return opens selected URLs.")
                Text("Cmd-Shift-Return opens every extracted URL.")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }
}
