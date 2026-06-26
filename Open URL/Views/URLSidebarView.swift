//
//  URLSidebarView.swift
//  Open URL
//

import SwiftUI

internal struct URLSidebarView: View {
    private enum Layout {
        static let spacingExtraSmall: CGFloat = 2
        static let spacingSmall: CGFloat = 10
        static let emptyStateSpacing: CGFloat = 8
        static let emptyStatePadding: CGFloat = 18
        static let cleanedBadgeHorizontalPadding: CGFloat = 6
        static let cleanedBadgeVerticalPadding: CGFloat = 2
    }

    internal let extractedURLs: [ExtractedURL]
    @Binding internal var selectedURLIDs: Set<ExtractedURL.ID>
    internal let onLoadClipboard: () -> Void

    internal var body: some View {
        List(selection: $selectedURLIDs) {
            Section {
                ForEach(extractedURLs) { extractedURL in
                    HStack(spacing: Layout.spacingSmall) {
                        Image(systemName: "link")
                            .accessibilityHidden(true)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: Layout.spacingExtraSmall) {
                            Text(extractedURL.hostDisplay)
                                .lineLimit(1)

                            Text(extractedURL.pathDisplay)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        if extractedURL.rawText != extractedURL.fullDisplay {
                            Text("Cleaned")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, Layout.cleanedBadgeHorizontalPadding)
                                .padding(.vertical, Layout.cleanedBadgeVerticalPadding)
                                .background(.quaternary.opacity(0.5), in: Capsule())
                        }
                    }
                    .tag(extractedURL.id)
                }
            } header: {
                Text("\(extractedURLs.count) URL\(extractedURLs.count == 1 ? "" : "s")")
            }
        }
        .listStyle(.sidebar)
        .overlay {
            if extractedURLs.isEmpty {
                VStack(spacing: Layout.emptyStateSpacing) {
                    Image(systemName: "link.slash")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)

                    Text("No URLs Found")
                        .font(.headline)

                    Text("Paste text, logs, emails, or markdown containing links.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Text("Press Cmd-Shift-L to load clipboard")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button("Load Clipboard", action: onLoadClipboard)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                }
                .frame(maxWidth: .infinity)
                .padding(Layout.emptyStatePadding)
            }
        }
    }
}
