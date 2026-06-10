//
//  WorkspaceCommandActions.swift
//  Open URL
//

import SwiftUI

internal struct WorkspaceCommandActions {
    internal let pasteFromClipboard: () -> Void
    internal let openSelected: () -> Void
    internal let openAll: () -> Void
    internal let copyExtractedURLs: () -> Void
    internal let clear: () -> Void
    internal let toggleInspector: () -> Void
    internal let canOpenSelected: Bool
    internal let canOpenAll: Bool
    internal let canCopy: Bool
}

private struct WorkspaceCommandActionsKey: FocusedValueKey {
    typealias Value = WorkspaceCommandActions
}

extension FocusedValues {
    internal var workspaceCommandActions: WorkspaceCommandActions? {
        get { self[WorkspaceCommandActionsKey.self] }
        set { self[WorkspaceCommandActionsKey.self] = newValue }
    }
}
