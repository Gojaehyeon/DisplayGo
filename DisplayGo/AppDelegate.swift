import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            let image = NSImage(systemSymbolName: "display", accessibilityDescription: "DisplayGo")
            image?.isTemplate = true // Ensures compatibility with dark mode
            button.image = image
            print("✅ Status bar icon successfully set.")
        } else {
            print("❌ Failed to get status item button.")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Swap Display", action: #selector(swapDisplayClicked), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "설정", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "종료", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu

        HotKeyManager.shared.registerDefaultHotKey()
        KeyboardMonitor.start()
    }

    @objc func swapDisplayClicked() {
        Task {
            do {
                try await swapMainDisplay()
            } catch {
                print("디스플레이 스왑 실패: \(error)")
            }
        }
    }
}
