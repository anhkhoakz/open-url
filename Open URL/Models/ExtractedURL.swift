//
//  ExtractedURL.swift
//  Open URL
//

import Foundation

internal struct ExtractedURL: Identifiable, Hashable {
    internal let id: UUID = UUID()
    internal let url: URL
    internal let rawText: String

    internal var hostDisplay: String {
        url.host(percentEncoded: false) ?? url.absoluteString
    }

    internal var pathDisplay: String {
        let path: String = url.path(percentEncoded: false)
        return path.isEmpty ? "/" : path
    }

    internal var fullDisplay: String {
        url.absoluteString
    }
}
