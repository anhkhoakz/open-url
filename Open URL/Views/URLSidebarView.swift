//
//  URLSidebarView.swift
//  Open URL
//

import SwiftUI

internal struct URLSidebarView: View {
    private enum Layout {
        static let spacingExtraSmall: CGFloat = 2
        static let spacingSmall: CGFloat = 10
    }

    internal let extractedURLs: [ExtractedURL]
    @Binding internal var selectedURLIDs: Set<ExtractedURL.ID>

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
                ContentUnavailableView(
                    "No URLs Yet",
                    systemImage: "link.slash",
                    description: Text(
                        "Paste text or load your clipboard to populate the list."
                    )
                )
            }
        }
    }
}
