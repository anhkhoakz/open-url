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
            )
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
                Button("Paste") {
                    workspace.loadClipboard(stripTrackingParameters: stripTrackingParameters)
                }
                .keyboardShortcut("l", modifiers: [.command, .shift])

                Button("Open Selected") {
                    workspace.openSelected(
                        selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier
                    )
                }
                .disabled(workspace.selectedURLs.isEmpty)

                Button("Open All") {
                    workspace.openAll(
                        selectedBrowserBundleIdentifier: selectedBrowserBundleIdentifier
                    )
                }
                .disabled(workspace.hasURLs == false)
            }

            ToolbarItemGroup {
                Button("Copy URLs") {
                    workspace.copyExtractedURLs()
                }
                .disabled(workspace.hasURLs == false)

                Button(
                    "Inspector",
                    systemImage: inspectorPresented ? "sidebar.trailing" : "sidebar.right"
                ) {
                    inspectorPresented.toggle()
                }
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
}
