# Open URL

A macOS menubar app that extracts URLs from selected text, strips tracking parameters, and opens them in your browser of choice.

## Features

- Extracts URLs from clipboard text or manual input via `NSDataDetector`
- Strips common tracking parameters (`fbclid`, `gclid`, `utm_*`, etc.)
- Lists all browsers detected on the system — open URLs with your preferred browser
- Supports multiple URL selection in a sidebar workspace
- Menu bar extra for quick access
- Workspace-style UI for managing batches of URLs

## Requirements

- macOS 14.0+ (Sonoma)
- Xcode 15+

## Build

```bash
xcodebuild -scheme "Open URL" -destination "platform=macOS" build
```

## Usage

1. Copy text containing URLs to your clipboard
2. Click the menu bar icon (link badge with plus) or open the app window
3. URLs are automatically extracted and deduplicated
4. Select URLs and open them in your system default browser — or pick a specific browser from the sidebar
