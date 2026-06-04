//
//  BrowserOption.swift
//  Open URL
//

import Foundation

struct BrowserOption: Identifiable, Hashable {
    let appURL: URL
    let bundleIdentifier: String
    let name: String
    let isDefault: Bool

    var id: String { bundleIdentifier }
}
