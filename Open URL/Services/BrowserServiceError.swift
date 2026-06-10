//
//  BrowserServiceError.swift
//  Open URL
//

import Foundation

internal enum BrowserServiceError: LocalizedError {
    case browserUnavailable
    case noURLsToOpen

    internal var errorDescription: String? {
        switch self {
        case .browserUnavailable:
            return "The selected browser is no longer available."

        case .noURLsToOpen:
            return "There are no URLs to open."
        }
    }
}
