//
//  URLWorkspace.swift
//  Open URL
//

import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class URLWorkspace {
    var sourceText = ""
    var extractedURLs: [ExtractedURL] = []
    var selectedURLIDs = Set<ExtractedURL.ID>()
    var availableBrowsers: [BrowserOption] = []
    var statusMessage = "Paste text or load the clipboard to extract URLs."

    private let browserService = BrowserService()
    private let extractionService = URLExtractionService()

    var hasURLs: Bool {
        extractedURLs.isEmpty == false
    }

    var selectedURLs: [ExtractedURL] {
        extractedURLs.filter { selectedURLIDs.contains($0.id) }
    }

    var previewURL: ExtractedURL? {
        selectedURLs.first ?? extractedURLs.first
    }

    private var extractionTask: Task<Void, Never>?
    private var reloadBrowsersTask: Task<Void, Never>?

    func configure(
        selectedBrowserBundleIdentifier: String,
        stripTrackingParameters: Bool
    ) {
        reloadBrowsers(selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier)
        refreshExtraction(stripTrackingParameters: stripTrackingParameters, debounce: false)
    }

    func refreshExtraction(stripTrackingParameters: Bool, debounce: Bool = true) {
        extractionTask?.cancel()

        extractionTask = Task {
            if debounce {
                do {
                    try await Task.sleep(nanoseconds: 150_000_000) // 150ms debounce
                } catch {
                    return // Task was cancelled during sleep
                }
            }

            let text = sourceText
            let refreshedURLs = await extractionService.extract(
                from: text,
                stripTrackingParameters: stripTrackingParameters
            )

            guard !Task.isCancelled else { return }

            let preservedURLStrings = Set(
                extractedURLs
                    .filter { selectedURLIDs.contains($0.id) }
                    .map(\.fullDisplay)
            )

            extractedURLs = refreshedURLs
            selectedURLIDs = Set(
                refreshedURLs
                    .filter { preservedURLStrings.contains($0.fullDisplay) }
                    .map(\.id)
            )

            if refreshedURLs.isEmpty {
                statusMessage = text.isEmpty
                    ? "Paste text or load the clipboard to extract URLs."
                    : "No valid URLs were detected in the current text."
            } else {
                statusMessage = "\(refreshedURLs.count) URL\(refreshedURLs.count == 1 ? "" : "s") ready to open."
            }
        }
    }

    func reloadBrowsers(selectedBrowserBundleIdentifier: String, force: Bool = false) {
        guard force || availableBrowsers.isEmpty else {
            checkPreferredBrowser(selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier)
            return
        }

        reloadBrowsersTask?.cancel()
        reloadBrowsersTask = Task {
            let browsers = await browserService.availableBrowsers()

            guard !Task.isCancelled else { return }

            availableBrowsers = browsers
            checkPreferredBrowser(selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier)
        }
    }

    private func checkPreferredBrowser(selectedBrowserBundleIdentifier: String) {
        if
            selectedBrowserBundleIdentifier.isEmpty == false,
            availableBrowsers.contains(where: { $0.bundleIdentifier == selectedBrowserBundleIdentifier }) == false {
            statusMessage = "The preferred browser is unavailable. OpenURL will fall back to the current default browser."
        }
    }

    func loadClipboard(stripTrackingParameters: Bool) {
        guard
            let clipboardText = NSPasteboard.general.string(forType: .string),
            clipboardText.isEmpty == false
        else {
            statusMessage = "The clipboard does not contain any text."
            return
        }

        sourceText = clipboardText
        refreshExtraction(stripTrackingParameters: stripTrackingParameters, debounce: false)
    }

    func clear() {
        extractionTask?.cancel()
        sourceText = ""
        extractedURLs = []
        selectedURLIDs.removeAll()
        statusMessage = "Cleared the current input."
    }

    func copyExtractedURLs() {
        guard hasURLs else {
            statusMessage = "There are no extracted URLs to copy."
            return
        }

        let combinedText = extractedURLs.map(\.fullDisplay).joined(separator: "\n")
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(combinedText, forType: .string)

        statusMessage = "Copied \(extractedURLs.count) URL\(extractedURLs.count == 1 ? "" : "s") to the clipboard."
    }

    func openAll(selectedBrowserBundleIdentifier: String) {
        open(
            extractedURLs.map(\.url),
            selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier,
            fallbackStatus: "There are no URLs to open."
        )
    }

    func openSelected(selectedBrowserBundleIdentifier: String) {
        open(
            selectedURLs.map(\.url),
            selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier,
            fallbackStatus: "Select at least one URL before opening."
        )
    }

    func openClipboardURLs(
        selectedBrowserBundleIdentifier: String,
        stripTrackingParameters: Bool
    ) {
        loadClipboard(stripTrackingParameters: stripTrackingParameters)
        openAll(selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier)
    }

    private func open(
        _ urls: [URL],
        selectedBrowserBundleIdentifier: String,
        fallbackStatus: String
    ) {
        guard urls.isEmpty == false else {
            statusMessage = fallbackStatus
            return
        }

        let browser = availableBrowsers.first {
            $0.bundleIdentifier == selectedBrowserBundleIdentifier
        }

        do {
            try browserService.open(urls: urls, with: browser)

            if let browser {
                statusMessage = "Opened \(urls.count) URL\(urls.count == 1 ? "" : "s") in \(browser.name)."
            } else {
                statusMessage = "Opened \(urls.count) URL\(urls.count == 1 ? "" : "s") in the default browser."
            }
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}
