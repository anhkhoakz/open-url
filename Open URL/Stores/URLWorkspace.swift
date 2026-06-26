//
//  URLWorkspace.swift
//  Open URL
//

import AppKit
import Foundation
import Observation

@MainActor
@Observable
internal final class URLWorkspace {
    private enum Constants {
        static let debounceNanoseconds: UInt64 = 150_000_000
    }

    internal var sourceText: String = ""
    internal var extractedURLs: [ExtractedURL] = []
    internal var selectedURLIDs: Set<ExtractedURL.ID> = Set<ExtractedURL.ID>()
    internal var availableBrowsers: [BrowserOption] = []
    internal var statusMessage: String = "Paste text or load the clipboard to extract URLs."

    private let browserService: BrowserService = BrowserService()
    private let extractionService: URLExtractionService = URLExtractionService()
    private var extractionTask: Task<Void, Never>?
    private var reloadBrowsersTask: Task<Void, Never>?

    internal var hasURLs: Bool {
        extractedURLs.isEmpty == false
    }

    internal var selectedURLs: [ExtractedURL] {
        extractedURLs.filter { selectedURLIDs.contains($0.id) }
    }

    internal var previewURL: ExtractedURL? {
        selectedURLs.first ?? extractedURLs.first
    }

    internal func configure(
        selectedBrowserBundleIdentifier: String,
        stripTrackingParameters: Bool
    ) {
        reloadBrowsers(selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier, force: false)
        refreshExtraction(
            stripTrackingParameters: stripTrackingParameters,
            debounce: false
        )
    }

    internal func refreshExtraction(
        stripTrackingParameters: Bool,
        debounce: Bool
    ) {
        extractionTask?.cancel()
        extractionTask = Task { [self] in
            await performExtraction(
                stripTrackingParameters: stripTrackingParameters,
                debounce: debounce
            )
        }
    }

    internal func reloadBrowsers(
        selectedBrowserBundleIdentifier: String,
        force: Bool
    ) {
        guard force || availableBrowsers.isEmpty else {
            checkPreferredBrowser(
                selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier
            )
            return
        }

        reloadBrowsersTask?.cancel()
        reloadBrowsersTask = Task {
            let browsers: [BrowserOption] = self.browserService.availableBrowsers()

            guard !Task.isCancelled else {
                return
            }

            self.availableBrowsers = browsers
            self.checkPreferredBrowser(
                selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier
            )
        }
    }

    internal func loadClipboard(stripTrackingParameters: Bool) {
        guard let clipboardText = clipboardText() else {
            statusMessage = "The clipboard does not contain any text."
            return
        }

        sourceText = clipboardText
        refreshExtraction(stripTrackingParameters: stripTrackingParameters, debounce: false)
    }

    internal func clear() {
        extractionTask?.cancel()
        sourceText = ""
        extractedURLs = []
        selectedURLIDs.removeAll()
        statusMessage = "Cleared the current input."
    }

    internal func copyExtractedURLs() {
        guard hasURLs else {
            statusMessage = "There are no extracted URLs to copy."
            return
        }

        let combinedText: String = extractedURLs.map(\.fullDisplay).joined(separator: "\n")
        let pasteboard: NSPasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(combinedText, forType: .string)

        statusMessage = "Copied \(extractedURLs.count) URL"
            + "\(extractedURLs.count == 1 ? "" : "s") to the clipboard."
    }

    internal func openAll(selectedBrowserBundleIdentifier: String) {
        open(
            extractedURLs.map(\.url),
            selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier,
            fallbackStatus: "There are no URLs to open."
        )
    }

    internal func openSelected(selectedBrowserBundleIdentifier: String) {
        open(
            selectedURLs.map(\.url),
            selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier,
            fallbackStatus: "Select at least one URL before opening."
        )
    }

    internal func openClipboardURLs(
        selectedBrowserBundleIdentifier: String,
        stripTrackingParameters: Bool
    ) {
        guard let clipboardText = clipboardText() else {
            statusMessage = "The clipboard does not contain any text."
            return
        }

        extractionTask?.cancel()
        sourceText = clipboardText

        let refreshedURLs: [ExtractedURL] = extractionService.extract(
            from: clipboardText,
            stripTrackingParameters: stripTrackingParameters
        )
        commitExtractionResult(refreshedURLs, sourceText: clipboardText)
        openAll(selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier)
    }

    private func clipboardText() -> String? {
        guard
            let clipboardText = NSPasteboard.general.string(forType: .string),
            clipboardText.isEmpty == false
        else {
            return nil
        }

        return clipboardText
    }

    private func checkPreferredBrowser(
        selectedBrowserBundleIdentifier: String
    ) {
        if
            selectedBrowserBundleIdentifier.isEmpty == false,
            availableBrowsers.contains(
                where: { browserElement in
                    browserElement.bundleIdentifier == selectedBrowserBundleIdentifier
                }
            ) == false {
            statusMessage = "The preferred browser is unavailable. "
                + "OpenURL will fall back to the current default browser."
        }
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

        let browser: BrowserOption? = availableBrowsers.first { browserElement in
            browserElement.bundleIdentifier == selectedBrowserBundleIdentifier
        }

        do {
            try browserService.open(urls: urls, with: browser)

            if let browser {
                statusMessage = "Opened \(urls.count) URL"
                    + "\(urls.count == 1 ? "" : "s") in \(browser.name)."
            } else {
                statusMessage = "Opened \(urls.count) URL"
                    + "\(urls.count == 1 ? "" : "s") in the default browser."
            }
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func performExtraction(
        stripTrackingParameters: Bool,
        debounce: Bool
    ) async {
        if debounce {
            do {
                try await Task.sleep(nanoseconds: Constants.debounceNanoseconds)
            } catch {
                return
            }
        }

        let text: String = sourceText
        let refreshedURLs: [ExtractedURL] = extractionService.extract(
            from: text,
            stripTrackingParameters: stripTrackingParameters
        )

        guard !Task.isCancelled else {
            return
        }

        commitExtractionResult(refreshedURLs, sourceText: text)
    }

    private func commitExtractionResult(
        _ refreshedURLs: [ExtractedURL],
        sourceText: String
    ) {
        let preservedURLStrings: Set<String> = Set<String>(
            extractedURLs
                .filter { selectedURLIDs.contains($0.id) }
                .map(\.fullDisplay)
        )

        extractedURLs = refreshedURLs
        selectedURLIDs = Set<ExtractedURL.ID>(
            refreshedURLs
                .filter { preservedURLStrings.contains($0.fullDisplay) }
                .map(\.id)
        )

        if refreshedURLs.isEmpty {
            statusMessage = sourceText.isEmpty
                ? "Paste text or load the clipboard to extract URLs."
                : "No valid URLs were detected in the current text."
        } else {
            statusMessage = "\(refreshedURLs.count) URL"
                + "\(refreshedURLs.count == 1 ? "" : "s") ready to open."
        }
    }

    deinit {}
}
