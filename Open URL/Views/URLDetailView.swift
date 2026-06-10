//
//  URLDetailView.swift
//  Open URL
//

import SwiftUI

struct URLDetailView: View {
    @Bindable var workspace: URLWorkspace

    let selectedBrowserBundleIdentifier: String
    let stripTrackingParameters: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                summarySection
                editorSection
                previewSection
            }
            .padding(24)
        }
        .background(.regularMaterial)
    }

    private var summarySection: some View {
        GroupBox {
            HStack(alignment: .top, spacing: 18) {
                summaryMetric(
                    title: "Detected",
                    value: "\(workspace.extractedURLs.count)",
                    systemImage: "link"
                )

                summaryMetric(
                    title: "Selected",
                    value: "\(workspace.selectedURLs.count)",
                    systemImage: "checkmark.circle"
                )

                summaryMetric(
                    title: "Browser",
                    value: selectedBrowserName,
                    systemImage: "globe"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Text("Session")
        }
    }

    private var editorSection: some View {
        GroupBox {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $workspace.sourceText)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 260)
                    .scrollContentBackground(.hidden)
                    .padding(.top, 2)
                    .onChange(of: workspace.sourceText) { _, _ in
                        workspace.refreshExtraction(stripTrackingParameters: stripTrackingParameters)
                    }

                if workspace.sourceText.isEmpty {
                    Text("Paste mixed text here. OpenURL extracts valid links in real time and keeps the source intact for review.")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 6)
                }
            }

            Text(workspace.statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 6)
        } label: {
            Text("Source Text")
        }
    }

    private var previewSection: some View {
        GroupBox {
            if let previewURL = workspace.previewURL {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label(previewURL.hostDisplay, systemImage: "safari")
                            .font(.headline)

                        Spacer()

                        Text(previewURL.schemeDisplay)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    Text(previewURL.fullDisplay)
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)

                    Text("Original match: \(previewURL.rawText)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No URL preview yet")
                        .font(.headline)

                    Text("Load the clipboard or paste text to inspect the extracted links before opening them.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } label: {
            Text("Preview")
        }
    }

    private var selectedBrowserName: String {
        if selectedBrowserBundleIdentifier.isEmpty {
            return "System Default"
        }

        return workspace.availableBrowsers
            .first { $0.bundleIdentifier == selectedBrowserBundleIdentifier }?
            .name ?? "System Default"
    }

    private func summaryMetric(title: String, value: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.weight(.semibold))
        }
        .frame(minWidth: 140, alignment: .leading)
    }
}
