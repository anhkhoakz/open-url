//
//  SelectionInspectorView.swift
//  Open URL
//

import SwiftUI

struct SelectionInspectorView: View {
    @Bindable var workspace: URLWorkspace
    @Binding var selectedBrowserBundleIdentifier: String
    @Binding var stripTrackingParameters: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                GroupBox("Open") {
                    VStack(alignment: .leading, spacing: 12) {
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

                GroupBox("Selection") {
                    VStack(alignment: .leading, spacing: 8) {
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

                GroupBox("Shortcuts") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cmd-Shift-L loads clipboard text.")
                        Text("Cmd-Return opens selected URLs.")
                        Text("Cmd-Shift-Return opens every extracted URL.")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .frame(minWidth: 260)
    }
}
