//
//  ContentView.swift
//  Open URL
//

import SwiftUI

internal struct ContentView: View {
    private enum Layout {
        static let columnWidthMin: CGFloat = 280
        static let columnWidthIdeal: CGFloat = 320
    }

    @Bindable internal var workspace: URLWorkspace
    @Binding internal var selectedBrowserBundleIdentifier: String
    @Binding internal var stripTrackingParameters: Bool

    @State private var inspectorPresented: Bool = true

    private var commandActions: WorkspaceCommandActions {
        WorkspaceCommandActions(
            pasteFromClipboard: {
                workspace.loadClipboard(stripTrackingParameters: stripTrackingParameters)
            },
            openSelected: {
                workspace.openSelected(
                    selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier
                )
            },
            openAll: {
                workspace.openAll(
                    selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier
                )
            },
            copyExtractedURLs: {
                workspace.copyExtractedURLs()
            },
            clear: {
                workspace.clear()
            },
            toggleInspector: {
                inspectorPresented.toggle()
            },
            canOpenSelected: workspace.selectedURLs.isEmpty == false,
            canOpenAll: workspace.hasURLs,
            canCopy: workspace.hasURLs
        )
    }

    internal var body: some View {
        NavigationSplitView {
            URLSidebarView(
                extractedURLs: workspace.extractedURLs,
                selectedURLIDs: $workspace.selectedURLIDs
            ) {
                workspace.loadClipboard(stripTrackingParameters: stripTrackingParameters)
            }
            .navigationSplitViewColumnWidth(
                min: Layout.columnWidthMin,
                ideal: Layout.columnWidthIdeal
            )
        } detail: {
            URLDetailView(
                workspace: workspace,
                selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier,
                stripTrackingParameters: stripTrackingParameters
            )
        }
        .navigationSplitViewStyle(.balanced)
        .focusedSceneValue(\.workspaceCommandActions, commandActions)
        .inspector(isPresented: $inspectorPresented) {
            SelectionInspectorView(
                workspace: workspace,
                selectedBrowserBundleIdentifier: $selectedBrowserBundleIdentifier,
                stripTrackingParameters: $stripTrackingParameters
            )
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                primaryToolbarActions
            }

            ToolbarItemGroup {
                secondaryToolbarActions
            }
        }
        .onAppear {
            workspace.configure(
                selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier,
                stripTrackingParameters: stripTrackingParameters
            )
        }
        .onChange(of: stripTrackingParameters) { _, newValue in
            workspace.refreshExtraction(
                stripTrackingParameters: newValue,
                debounce: false
            )
        }
        .onChange(of: selectedBrowserBundleIdentifier) { _, newValue in
            workspace.reloadBrowsers(selectedBrowserBundleIdentifier: newValue, force: false)
        }
    }

    @ViewBuilder
    private var primaryToolbarActions: some View {
        loadClipboardButton
        openSelectedButton
        openAllButton
    }

    @ViewBuilder
    private var secondaryToolbarActions: some View {
        copyURLsButton
        inspectorButton
    }

    private var loadClipboardButton: some View {
        Group {
            if workspace.hasURLs {
                Button("Load Clipboard") {
                    workspace.loadClipboard(stripTrackingParameters: stripTrackingParameters)
                }
                .buttonStyle(.bordered)
            } else {
                Button("Load Clipboard") {
                    workspace.loadClipboard(stripTrackingParameters: stripTrackingParameters)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .keyboardShortcut("l", modifiers: [.command, .shift])
    }

    private var openSelectedButton: some View {
        Group {
            if workspace.selectedURLs.isEmpty == false {
                Button("Open Selected") {
                    workspace.openSelected(
                        selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier
                    )
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Open Selected") {
                    workspace.openSelected(
                        selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier
                    )
                }
                .buttonStyle(.bordered)
            }
        }
        .disabled(workspace.selectedURLs.isEmpty)
    }

    private var openAllButton: some View {
        Group {
            if workspace.hasURLs && workspace.selectedURLs.isEmpty {
                Button("Open All") {
                    workspace.openAll(
                        selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier
                    )
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Open All") {
                    workspace.openAll(
                        selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier
                    )
                }
                .buttonStyle(.bordered)
            }
        }
        .disabled(workspace.hasURLs == false)
    }

    private var copyURLsButton: some View {
        Button("Copy URLs") {
            workspace.copyExtractedURLs()
        }
        .disabled(workspace.hasURLs == false)
        .buttonStyle(.bordered)
    }

    private var inspectorButton: some View {
        Button(
            "Inspector",
            systemImage: inspectorPresented ? "sidebar.trailing" : "sidebar.right"
        ) {
            inspectorPresented.toggle()
        }
        .buttonStyle(.bordered)
    }
}
