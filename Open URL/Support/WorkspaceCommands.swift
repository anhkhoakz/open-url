//
//  WorkspaceCommands.swift
//  Open URL
//

import SwiftUI

struct WorkspaceCommandActions {
    let pasteFromClipboard: () -> Void
    let openSelected: () -> Void
    let openAll: () -> Void
    let copyExtractedURLs: () -> Void
    let clear: () -> Void
    let toggleInspector: () -> Void
    let canOpenSelected: Bool
    let canOpenAll: Bool
    let canCopy: Bool
}

private struct WorkspaceCommandActionsKey: FocusedValueKey {
    typealias Value = WorkspaceCommandActions
}

extension FocusedValues {
    var workspaceCommandActions: WorkspaceCommandActions? {
        get { self[WorkspaceCommandActionsKey.self] }
        set { self[WorkspaceCommandActionsKey.self] = newValue }
    }
}

struct WorkspaceCommands: Commands {
    @FocusedValue(\.workspaceCommandActions)
    private var actions

    var body: some Commands {
        CommandMenu("Action") {
            Button("Paste From Clipboard") {
                actions?.pasteFromClipboard()
            }
            .keyboardShortcut("l", modifiers: [.command, .shift])

            Button("Open Selected URLs") {
                actions?.openSelected()
            }
            .keyboardShortcut(.return, modifiers: [.command])
            .disabled(actions?.canOpenSelected == false)

            Button("Open All URLs") {
                actions?.openAll()
            }
            .keyboardShortcut(.return, modifiers: [.command, .shift])
            .disabled(actions?.canOpenAll == false)

            Divider()

            Button("Copy Extracted URLs") {
                actions?.copyExtractedURLs()
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
            .disabled(actions?.canCopy == false)

            Button("Clear Input") {
                actions?.clear()
            }
            .keyboardShortcut("k", modifiers: [.command])

            Divider()

            Button("Toggle Inspector") {
                actions?.toggleInspector()
            }
            .keyboardShortcut("i", modifiers: [.command, .option])
        }
    }
}
