import Cocoa
import HotKey

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var isKorean: Bool { Locale.preferredLanguages.first?.hasPrefix("ko") == true }
    var hotKeyMenuItem: NSMenuItem?
    var hotKeyPopover: NSPopover?

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
        menu.addItem(NSMenuItem(title: "🖥️ Swap Display", action: #selector(swapDisplayClicked), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        let hotKeyTitle = isKorean ? "⌨️ 단축키 변경 (" : "⌨️ Change Hotkey ("
        let hotKeyItem = NSMenuItem(title: hotKeyTitle + HotKeyManager.shared.currentHotKeyDescription() + ")", action: #selector(changeHotKeyClicked), keyEquivalent: "")
        menu.addItem(hotKeyItem)
        self.hotKeyMenuItem = hotKeyItem
        menu.addItem(NSMenuItem.separator())
        let quitTitle = isKorean ? "❌ 종료" : "❌ Quit"
        menu.addItem(NSMenuItem(title: quitTitle, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu

        HotKeyManager.shared.registerDefaultHotKey()
        KeyboardMonitor.start()

        NotificationCenter.default.addObserver(self, selector: #selector(updateHotKeyMenuItem), name: HotKeyManager.hotKeyChangedNotification, object: nil)
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

    @objc func updateHotKeyMenuItem() {
        let hotKeyTitle = isKorean ? "⌨️ 단축키 변경 (" : "⌨️ Change Hotkey ("
        hotKeyMenuItem?.title = hotKeyTitle + HotKeyManager.shared.currentHotKeyDescription() + ")"
    }

    @objc func changeHotKeyClicked() {
        print("단축키 변경 메뉴 클릭됨")
        if hotKeyPopover == nil {
            hotKeyPopover = NSPopover()
            hotKeyPopover?.contentViewController = HotKeyPopoverViewController()
            hotKeyPopover?.behavior = .transient
        }
        if let button = statusItem?.button, let popover = hotKeyPopover {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        }
    }
}
