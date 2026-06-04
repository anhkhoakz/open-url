//
//  ExtractedURL.swift
//  Open URL
//

import Foundation

struct ExtractedURL: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let rawText: String

    var hostDisplay: String {
        url.host(percentEncoded: false) ?? url.absoluteString
    }

    var pathDisplay: String {
        let path = url.path(percentEncoded: false)
        return path.isEmpty ? "/" : path
    }

    var fullDisplay: String {
        url.absoluteString
    }

    var schemeDisplay: String {
        url.scheme?.uppercased() ?? "URL"
    }
}
