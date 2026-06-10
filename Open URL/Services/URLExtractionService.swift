//
//  URLExtractionService.swift
//  Open URL
//

import Foundation

internal struct URLExtractionService {
    private let detector: NSDataDetector? = try? NSDataDetector(
        types: NSTextCheckingResult.CheckingType.link.rawValue
    )
    private let trackingParameters: Set<String> = Set<String>([
        "fbclid",
        "gclid",
        "igshid",
        "mc_cid",
        "mc_eid",
        "rdt",
        "si"
    ])

    internal func extract(
        from sourceText: String,
        stripTrackingParameters: Bool
    ) -> [ExtractedURL] {
        guard
            sourceText.isEmpty == false,
            let detector
        else {
            return []
        }

        let fullRange: NSRange = NSRange(
            sourceText.startIndex..<sourceText.endIndex,
            in: sourceText
        )
        let matches: [NSTextCheckingResult] = detector.matches(in: sourceText, options: [], range: fullRange)

        var seenURLs: Set<String> = Set<String>()
        var extractedURLs: [ExtractedURL] = []

        for match in matches {
            guard
                let matchedRange: Range<String.Index> = Range(match.range, in: sourceText),
                let normalizedURL: URL = normalizeURL(
                    rawMatch: String(sourceText[matchedRange]),
                    fallback: match.url,
                    stripTrackingParameters: stripTrackingParameters
                )
            else {
                continue
            }

            let dedupeKey: String = normalizedURL.absoluteString.lowercased()
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
        let trimmedMatch: String = trimNoise(from: rawMatch)
        let resolvedURL: URL? = URL(string: trimmedMatch) ?? fallback

        guard
            var components: URLComponents = resolvedURL.flatMap({ url in
                URLComponents(url: url, resolvingAgainstBaseURL: false)
            })
        else {
            return nil
        }

        if stripTrackingParameters, let queryItems: [URLQueryItem] = components.queryItems {
            let filteredQueryItems: [URLQueryItem] = queryItems.filter { item in
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
        let trimmed: String = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ""
        }

        let leadingNoise: CharacterSet = CharacterSet(charactersIn: "\"'`([<{")
        let trailingNoise: CharacterSet = CharacterSet(charactersIn: "\"'`.,;:!?]}>")

        var startIndex: String.Index = trimmed.startIndex
        var endIndex: String.Index = trimmed.endIndex
        let unicodeScalars: String.UnicodeScalarView = trimmed.unicodeScalars

        while startIndex < endIndex, leadingNoise.contains(unicodeScalars[startIndex]) {
            startIndex = trimmed.index(after: startIndex)
        }

        while startIndex < endIndex {
            let lastIndex: String.Index = trimmed.index(before: endIndex)
            if trailingNoise.contains(unicodeScalars[lastIndex]) {
                endIndex = lastIndex
            } else {
                break
            }
        }

        var substring: Substring = trimmed[startIndex..<endIndex]

        var openCount: Int = 0
        var closeCount: Int = 0
        for char in substring {
            if char == "(" {
                openCount += 1
            } else if char == ")" {
                closeCount += 1
            }
        }

        while substring.last == ")", openCount < closeCount {
            substring = substring.dropLast()
            closeCount -= 1
        }

        return String(substring)
    }
}
