//
//  BrowserService.swift
//  Open URL
//

import AppKit
import Foundation

enum BrowserServiceError: LocalizedError {
    case noURLsToOpen
    case browserUnavailable

    var errorDescription: String? {
        switch self {
        case .noURLsToOpen:
            return "There are no URLs to open."

        case .browserUnavailable:
            return "The selected browser is no longer available."
        }
    }
}

struct BrowserService {
    func availableBrowsers() -> [BrowserOption] {
        guard let sampleURL = URL(string: "https://example.com") else {
            return []
        }

        let workspace = NSWorkspace.shared
        let defaultAppURL = workspace.urlForApplication(toOpen: sampleURL)
        let defaultBundleIdentifier = defaultAppURL.flatMap { Bundle(url: $0)?.bundleIdentifier }

        let browserAppURLs = Array(workspace.urlsForApplications(toOpen: sampleURL))

        var options = browserAppURLs.compactMap { appURL -> BrowserOption? in
            guard
                let bundle = Bundle(url: appURL),
                let bundleIdentifier = bundle.bundleIdentifier
            else {
                return nil
            }

            let localizedName = FileManager.default.displayName(atPath: appURL.path)
            return BrowserOption(
                appURL: appURL,
                bundleIdentifier: bundleIdentifier,
                name: localizedName,
                isDefault: bundleIdentifier == defaultBundleIdentifier
            )
        }

        if
            let defaultAppURL,
            let bundle = Bundle(url: defaultAppURL),
            let bundleIdentifier = bundle.bundleIdentifier,
            options.contains(where: { $0.bundleIdentifier == bundleIdentifier }) == false {
            options.append(
                BrowserOption(
                    appURL: defaultAppURL,
                    bundleIdentifier: bundleIdentifier,
                    name: FileManager.default.displayName(atPath: defaultAppURL.path),
                    isDefault: true
                )
            )
        }

        var seenBundleIdentifiers = Set<String>()

        return options
            .filter { seenBundleIdentifiers.insert($0.bundleIdentifier).inserted }
            .sorted { lhs, rhs in
                if lhs.isDefault != rhs.isDefault {
                    return lhs.isDefault && !rhs.isDefault
                }

                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
    }

    func open(urls: [URL], with browser: BrowserOption?) throws {
        guard urls.isEmpty == false else {
            throw BrowserServiceError.noURLsToOpen
        }

        if let browser {
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true

            for url in urls {
                NSWorkspace.shared.open(
                    [url],
                    withApplicationAt: browser.appURL,
                    configuration: configuration
                ) { _, error in
                    if let error {
                        NSLog("OpenURL failed to open %@ via %@: %@", url.absoluteString, browser.name, error.localizedDescription)
                    }
                }
            }

            return
        }

        for url in urls {
            NSWorkspace.shared.open(url)
        }
    }
}
