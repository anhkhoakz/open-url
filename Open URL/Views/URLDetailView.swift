//
//  URLDetailView.swift
//  Open URL
//

import SwiftUI

internal struct URLDetailView: View {
    private enum Layout {
        static let spacingLarge: CGFloat = 18
        static let spacingMedium: CGFloat = 12
        static let spacingSmall: CGFloat = 8
        static let spacingExtraSmall: CGFloat = 6
        static let spacingTiny: CGFloat = 2
        static let paddingLarge: CGFloat = 24
        static let paddingMedium: CGFloat = 8
        static let minHeightEditor: CGFloat = 260
        static let minWidthMetric: CGFloat = 140
    }

    @Bindable internal var workspace: URLWorkspace

    internal let selectedBrowserBundleIdentifier: String
    internal let stripTrackingParameters: Bool

    internal var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.spacingLarge) {
                summarySection
                editorSection
                previewSection
            }
            .padding(Layout.paddingLarge)
        }
        .background(.regularMaterial)
    }

    private var summarySection: some View {
        GroupBox {
            HStack(alignment: .top, spacing: Layout.spacingLarge) {
                summaryMetric(
                    title: "Detected",
                    value: "\(workspace.extractedURLs.count) URLs",
                    systemImage: "link"
                )

                summaryMetric(
                    title: "Selected",
                    value: "\(workspace.selectedURLs.count) URLs",
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
            VStack(alignment: .leading, spacing: Layout.spacingTiny) {
                Text("Session")
                Text("Source text, extracted URLs, and the active browser.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var editorSection: some View {
        GroupBox {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $workspace.sourceText)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: Layout.minHeightEditor)
                    .scrollContentBackground(.hidden)
                    .padding(.top, Layout.spacingTiny)
                    .onChange(of: workspace.sourceText) { _, _ in
                        workspace.refreshExtraction(
                            stripTrackingParameters: stripTrackingParameters, debounce: false
                        )
                    }

                if workspace.sourceText.isEmpty {
                    Text(
                        "Paste text containing URLs here. Links will be extracted automatically "
                            + "without changing your source text."
                    )
                    .foregroundStyle(.secondary)
                    .padding(.top, Layout.paddingMedium)
                    .padding(.leading, Layout.spacingExtraSmall)
                }
            }

            Text(workspace.statusMessage)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Layout.spacingExtraSmall)
        } label: {
            VStack(alignment: .leading, spacing: Layout.spacingTiny) {
                Text("Source Text")
                Text("Paste or load text containing URLs.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var previewSection: some View {
        GroupBox {
            previewContent
        } label: {
            VStack(alignment: .leading, spacing: Layout.spacingTiny) {
                Text("Preview")
                Text("Review the cleaned destination before opening.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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

    @ViewBuilder
    private var previewContent: some View {
        if let previewURL = workspace.previewURL {
            previewURLContent(previewURL)
        } else {
            previewEmptyContent
        }
    }

    private func previewURLContent(_ previewURL: ExtractedURL) -> some View {
        VStack(alignment: .leading, spacing: Layout.spacingMedium) {
            HStack {
                Label(previewURL.hostDisplay, systemImage: "safari")
                    .font(.headline)

                Spacer()

                if stripTrackingParameters {
                    Text(previewURL.rawText == previewURL.fullDisplay ? "Clean" : "Tracking cleaned")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            LabeledContent("Original", value: previewURL.rawText)
                .font(.footnote)
                .foregroundStyle(.secondary)

            LabeledContent("Cleaned", value: previewURL.fullDisplay)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)

            LabeledContent("Domain", value: previewURL.hostDisplay)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var previewEmptyContent: some View {
        VStack(alignment: .leading, spacing: Layout.spacingSmall) {
            Text("No URL selected")
                .font(.headline)

            Text(
                workspace.hasURLs
                    ? "Select a URL on the left to preview it here."
                    : "Extracted URLs will appear on the left after you paste or load text."
            )
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func summaryMetric(
        title: String,
        value: String,
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: Layout.spacingExtraSmall) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.weight(.semibold))
        }
        .frame(minWidth: Layout.minWidthMetric, alignment: .leading)
    }
}
