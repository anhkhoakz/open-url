//
//  SelectionInspectorView.swift
//  Open URL
//

import SwiftUI

internal struct SelectionInspectorView: View {
    private enum Layout {
        static let spacingLarge: CGFloat = 22
        static let spacingMedium: CGFloat = 12
        static let spacingSmall: CGFloat = 8
        static let minWidthInspector: CGFloat = 260
        static let shortcutKeyWidth: CGFloat = 74
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
        GroupBox("Open With") {
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
                    .toggleStyle(.switch)
            }
        }
    }

    private var selectionSection: some View {
        GroupBox("Current Selection") {
            VStack(alignment: .leading, spacing: Layout.spacingSmall) {
                LabeledContent("Detected", value: "\(workspace.extractedURLs.count) URLs")
                LabeledContent("Selected", value: "\(workspace.selectedURLs.count) URLs")

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
        GroupBox("Keyboard Shortcuts") {
            VStack(alignment: .leading, spacing: Layout.spacingSmall) {
                shortcutRow(keys: "⌘⇧L", action: "Load Clipboard")
                shortcutRow(keys: "⌘↩", action: "Open Selected")
                shortcutRow(keys: "⌘⇧↩", action: "Open All")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    private func shortcutRow(keys: String, action: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Layout.spacingMedium) {
            Text(keys)
                .font(.system(.footnote, design: .monospaced).weight(.semibold))
                .frame(width: Layout.shortcutKeyWidth, alignment: .leading)

            Text(action)
        }
    }
}
