//
//  BrowserService.swift
//  Open URL
//

import AppKit
import Foundation

internal struct BrowserService {
    internal func availableBrowsers() -> [BrowserOption] {
        guard let sampleURL: URL = URL(string: "https://example.com") else {
            return []
        }

        let workspace: NSWorkspace = NSWorkspace.shared
        let defaultAppURL: URL? = workspace.urlForApplication(toOpen: sampleURL)
        let defaultBundleIdentifier: String? = defaultAppURL
            .flatMap { Bundle(url: $0)?.bundleIdentifier }

        let browserAppURLs: [URL] = Array(workspace.urlsForApplications(toOpen: sampleURL))

        var options: [BrowserOption] = browserAppURLs.compactMap { appURL -> BrowserOption? in
            guard
                let bundle: Bundle = Bundle(url: appURL),
                let bundleIdentifier: String = bundle.bundleIdentifier
            else {
                return nil
            }

            let localizedName: String = FileManager.default.displayName(atPath: appURL.path)
            return BrowserOption(
                appURL: appURL,
                bundleIdentifier: bundleIdentifier,
                name: localizedName,
                isDefault: bundleIdentifier == defaultBundleIdentifier
            )
        }

        if
            let defaultAppURL,
            let bundle: Bundle = Bundle(url: defaultAppURL),
            let bundleIdentifier: String = bundle.bundleIdentifier,
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

        var seenBundleIdentifiers: Set<String> = Set<String>()

        return options
            .filter { seenBundleIdentifiers.insert($0.bundleIdentifier).inserted }
            .sorted { lhs, rhs in
                if lhs.isDefault != rhs.isDefault {
                    return lhs.isDefault && !rhs.isDefault
                }

                return lhs.name
                    .localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
    }

    internal func open(urls: [URL], with browser: BrowserOption?) throws {
        guard urls.isEmpty == false else {
            throw BrowserServiceError.noURLsToOpen
        }

        if let browser {
            openWithBrowser(urls: urls, browser: browser)
            return
        }

        for url in urls {
            NSWorkspace.shared.open(url)
        }
    }

    private func openWithBrowser(urls: [URL], browser: BrowserOption) {
        let configuration: NSWorkspace.OpenConfiguration = NSWorkspace.OpenConfiguration()
        configuration.activates = true

        for url in urls {
            NSWorkspace.shared.open(
                [url],
                withApplicationAt: browser.appURL,
                configuration: configuration
            ) { _, error in
                if let error {
                    NSLog(
                        "OpenURL failed to open %@ via %@: %@",
                        url.absoluteString,
                        browser.name,
                        error.localizedDescription
                    )
                }
            }
        }
    }
}
