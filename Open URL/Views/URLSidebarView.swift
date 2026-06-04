//
//  URLSidebarView.swift
//  Open URL
//

import SwiftUI

struct URLSidebarView: View {
    let extractedURLs: [ExtractedURL]
    @Binding var selectedURLIDs: Set<ExtractedURL.ID>

    var body: some View {
        List(selection: $selectedURLIDs) {
            Section {
                ForEach(extractedURLs) { extractedURL in
                    HStack(spacing: 10) {
                        Image(systemName: "link")
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 2) {
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
                    description: Text("Paste text or load your clipboard to populate the list.")
                )
            }
        }
    }
}
