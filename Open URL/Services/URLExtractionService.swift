//
//  URLExtractionService.swift
//  Open URL
//

import Foundation

struct URLExtractionService {
    private let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    private let trackingParameters = Set([
        "fbclid",
        "gclid",
        "igshid",
        "mc_cid",
        "mc_eid",
        "rdt",
        "si"
    ])

    func extract(from sourceText: String, stripTrackingParameters: Bool) -> [ExtractedURL] {
        guard
            sourceText.isEmpty == false,
            let detector
        else {
            return []
        }

        let fullRange = NSRange(sourceText.startIndex..<sourceText.endIndex, in: sourceText)
        let matches = detector.matches(in: sourceText, options: [], range: fullRange)

        var seenURLs = Set<String>()
        var extractedURLs: [ExtractedURL] = []

        for match in matches {
            guard
                let matchedRange = Range(match.range, in: sourceText),
                let normalizedURL = normalizeURL(
                    rawMatch: String(sourceText[matchedRange]),
                    fallback: match.url,
                    stripTrackingParameters: stripTrackingParameters
                )
            else {
                continue
            }

            let dedupeKey = normalizedURL.absoluteString.lowercased()
            guard seenURLs.insert(dedupeKey).inserted else {
                continue
            }

            extractedURLs.append(
                ExtractedURL(
                    url: normalizedURL,
                    rawText: String(sourceText[matchedRange])
                )
            )
        }

        return extractedURLs
    }

    private func normalizeURL(
        rawMatch: String,
        fallback: URL?,
        stripTrackingParameters: Bool
    ) -> URL? {
        let trimmedMatch = trimNoise(from: rawMatch)
        let resolvedURL = URL(string: trimmedMatch) ?? fallback

        guard
            var components = resolvedURL.flatMap({
                URLComponents(url: $0, resolvingAgainstBaseURL: false)
            })
        else {
            return nil
        }

        if stripTrackingParameters, let queryItems = components.queryItems {
            let filteredQueryItems = queryItems.filter { item in
                guard item.name.hasPrefix("utm_") == false else {
                    return false
                }

                return trackingParameters.contains(item.name.lowercased()) == false
            }

            components.queryItems = filteredQueryItems.isEmpty ? nil : filteredQueryItems
        }

        return components.url
    }

    private func trimNoise(from value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        let leadingNoise = CharacterSet(charactersIn: "\"'`([<{")
        let trailingNoise = CharacterSet(charactersIn: "\"'`.,;:!?]}>")

        var startIndex = trimmed.startIndex
        var endIndex = trimmed.endIndex
        let unicodeScalars = trimmed.unicodeScalars

        // Trim leading noise
        while startIndex < endIndex, leadingNoise.contains(unicodeScalars[startIndex]) {
            startIndex = trimmed.index(after: startIndex)
        }

        // Trim trailing noise
        while startIndex < endIndex {
            let lastIndex = trimmed.index(before: endIndex)
            if trailingNoise.contains(unicodeScalars[lastIndex]) {
                endIndex = lastIndex
            } else {
                break
            }
        }

        var substring = trimmed[startIndex..<endIndex]

        // Handle unbalanced closing parentheses at the end.
        // E.g., "(https://example.com/page)" gets trimmed at the start to "https://example.com/page)",
        // which leaves an unbalanced ")". We count open and close parentheses to detect this.
        var openCount = 0
        var closeCount = 0
        for char in substring {
            if char == "(" { openCount += 1 } else if char == ")" { closeCount += 1 }
        }

        while substring.last == ")", openCount < closeCount {
            substring = substring.dropLast()
            closeCount -= 1
        }

        return String(substring)
    }
}
