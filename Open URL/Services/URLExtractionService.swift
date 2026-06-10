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
        var candidate = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let leadingNoise = CharacterSet(charactersIn: "\"'`([<{")
        let trailingNoise = CharacterSet(charactersIn: "\"'`.,;:!?]}>")

        while
            let firstScalar = candidate.unicodeScalars.first,
            leadingNoise.contains(firstScalar) {
            candidate.removeFirst()
        }

        while
            let lastScalar = candidate.unicodeScalars.last,
            trailingNoise.contains(lastScalar) {
            candidate.removeLast()
        }

        while candidate.last == ")", candidate.filter({ $0 == "(" }).count < candidate.filter({ $0 == ")" }).count {
            candidate.removeLast()
        }

        return candidate
    }
}
