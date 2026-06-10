//
//  BrowserOption.swift
//  Open URL
//

import Foundation

internal struct BrowserOption: Identifiable, Hashable {
    internal let appURL: URL
    internal let bundleIdentifier: String
    internal let name: String
    internal let isDefault: Bool

    internal var id: String {
        bundleIdentifier
    }
}
