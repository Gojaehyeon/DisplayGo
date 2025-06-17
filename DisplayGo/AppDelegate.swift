import Cocoa
import HotKey
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var isKorean: Bool { Locale.preferredLanguages.first?.hasPrefix("ko") == true }
    var hotKeyMenuItem: NSMenuItem?
    var hotKeyPopover: NSPopover?
    let sleepManager = PreventSleepManager()
    
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
        
        // About item
        let aboutItem = NSMenuItem(title: isKorean ? "DisplayGo 정보" : "About DisplayGo", action: #selector(showAbout), keyEquivalent: "")
        menu.addItem(aboutItem)
        
        // How to use item
        let howToItem = NSMenuItem(title: isKorean ? "사용 방법" : "How to use?", action: #selector(showHowToUse), keyEquivalent: "")
        menu.addItem(howToItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Swap Display item
//        let swapItem = NSMenuItem(title: isKorean ? "디스플레이 전환" : "Swap Display", action: #selector(swapDisplayClicked), keyEquivalent: "")
//        menu.addItem(swapItem)
        
        // Open Display Settings item
        let openSettingsItem = NSMenuItem(title: isKorean ? "디스플레이 설정 열기" : "Open Display Settings", action: #selector(openDisplaySettings), keyEquivalent: "")
        menu.addItem(openSettingsItem)
        
        // Change Hotkey item
        let hotKeyTitle = isKorean ? "단축키 변경 (" : "Change Hotkey ("
        let hotKeyItem = NSMenuItem(title: hotKeyTitle + HotKeyManager.shared.currentHotKeyDescription() + ")", action: #selector(changeHotKeyClicked), keyEquivalent: "")
        menu.addItem(hotKeyItem)
        self.hotKeyMenuItem = hotKeyItem
        menu.addItem(NSMenuItem.separator())

        // Add Sleep Prevention menu item with inline duration buttons
        let preventSleepItem = NSMenuItem()
        preventSleepItem.view?.setFrameSize(NSSize(width: 280, height: 70))  // Increased height
        let preventSleepHostingView = NSHostingView(rootView: PreventSleepView(sleepManager: sleepManager))
        preventSleepHostingView.frame = NSRect(x: 0, y: 0, width: 280, height: 70)  // Increased height
        preventSleepItem.view = preventSleepHostingView
        menu.addItem(preventSleepItem)

        menu.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitTitle = isKorean ? "종료" : "Quit"
        let quitItem = NSMenuItem(title: quitTitle, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
        
        HotKeyManager.shared.registerDefaultHotKey()
        KeyboardMonitor.start()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateHotKeyMenuItem), name: HotKeyManager.hotKeyChangedNotification, object: nil)
        
        showOnboardingIfNeeded()
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
        let hotKeyTitle = isKorean ? "단축키 변경 (" : "Change Hotkey ("
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
    
    @objc func showAbout() {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let copyright = info?["NSHumanReadableCopyright"] as? String ?? "All rights reserved, 2025 gojaehyun"
        let appName = "DisplayGo"
        let madeBy = "Made by Gojaehyun, who loves Jesus"
        let versionText = isKorean ? "버전 " : "Version "
        
        // 아이콘 (옵셔널 안전 처리)
        let iconImage = NSApp.applicationIconImage ?? NSImage()
        let iconView = NSImageView(image: iconImage)
        iconView.frame = NSRect(x: 0, y: 0, width: 64, height: 64)
        iconView.imageScaling = .scaleProportionallyUpOrDown
        
        // 라벨들
        let nameLabel = NSTextField(labelWithString: appName)
        nameLabel.font = NSFont.boldSystemFont(ofSize: 22)
        nameLabel.alignment = .center
        let versionLabel = NSTextField(labelWithString: versionText + version)
        versionLabel.font = NSFont.systemFont(ofSize: 15)
        versionLabel.alignment = .center
        let copyrightLabel = NSTextField(labelWithString: copyright)
        copyrightLabel.font = NSFont.systemFont(ofSize: 13)
        copyrightLabel.alignment = .center
        let madeByLabel = NSTextField(labelWithString: madeBy)
        madeByLabel.font = NSFont.systemFont(ofSize: 13)
        madeByLabel.textColor = NSColor.secondaryLabelColor
        madeByLabel.alignment = .center
        
        // StackView로 정렬 (enum 네임스페이스 제거)
        let stack = NSStackView(views: [iconView, nameLabel, versionLabel, copyrightLabel, madeByLabel])
        stack.orientation = NSUserInterfaceLayoutOrientation.vertical
        stack.spacing = 12
        stack.alignment = NSLayoutConstraint.Attribute.centerX
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 340, height: 320),
                            styleMask: [.titled, .closable],
                            backing: .buffered, defer: false)
        panel.title = appName
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.center()
        panel.contentView?.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: panel.contentView!.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: panel.contentView!.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: panel.contentView!.widthAnchor, multiplier: 0.9)
        ])
        
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }
    
    func showOnboardingIfNeeded() {
        let defaults = UserDefaults.standard
        let hasLaunchedKey = "hasLaunchedBefore"
        if !defaults.bool(forKey: hasLaunchedKey) {
            defaults.set(true, forKey: hasLaunchedKey)
            let message = isKorean
            ? """
                ✔️ 이 앱은 메뉴바 앱입니다.
                기본 단축키는 ⌘ + ⌥ + 1이며, 변경 가능합니다.
                ✔️ 메뉴바 앱이 실행 중이어야 작동합니다.
                """
            : """
                ✔️ This is a menu bar app.
                The default shortcut is ⌘ + ⌥ + 1, and it can be changed.
                ✔️ The app must be running in the menu bar to work.
                """
            
            let alert = NSAlert()
            alert.messageText = isKorean ? "DisplayGo 사용 방법" : "How to Use DisplayGo"
            alert.informativeText = message
            alert.alertStyle = .informational
            alert.addButton(withTitle: isKorean ? "확인" : "OK")
            alert.runModal()
        }
    }
    @objc func showHowToUse() {
        let message = isKorean
        ? """
            사용방법: 앱을 실행 후 원하는 단축키를 설정하면 됩니다.
            (기본 단축키는 ⌘ + ⌥ + 1)

            * 아직 두 개 이상의 디스플레이는 지원하지 않습니다.
            * 메뉴바 앱이 실행 중이어야 작동하며, 독에는 앱이 보이지 않는 게 정상입니다.
            * 잠자기 방지 기능을 사용할 수 있습니다.
            """
        : """
            How to use: Launch the app and set your preferred shortcut.
            (The default shortcut is ⌘ + ⌥ + 1)

            * Currently does not support more than two displays.
            * The app must be running in the menu bar and it is normal that it does not appear in the Dock.
            * You can use the sleep prevention feature from the menu.
            """
        
        let alert = NSAlert()
        alert.messageText = isKorean ? "DisplayGo 사용 방법" : "How to Use DisplayGo"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: isKorean ? "확인" : "OK")
        alert.runModal()
    }
    @objc func openDisplaySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.displays") {
            NSWorkspace.shared.open(url)
        }
    }
}
