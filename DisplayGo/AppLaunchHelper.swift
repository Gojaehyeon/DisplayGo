import AppKit
import SwiftUI

func openSettingsWindow(shortcutManager: ShortcutManager) {
    NSApp.setActivationPolicy(.regular)

    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
        styleMask: [.titled, .closable],
        backing: .buffered,
        defer: false
    )

    window.center()
    window.title = "환경설정"
    window.contentView = NSHostingView(
        rootView: ContentView()
            .environmentObject(shortcutManager)
    )

    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
}