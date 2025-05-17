import Foundation
import HotKey
import AppKit

final class HotKeyManager {
    static let shared = HotKeyManager()
    static let hotKeyChangedNotification = Notification.Name("HotKeyManagerHotKeyChanged")

    private var hotKey: HotKey?

    func registerDefaultHotKey() {
        hotKey = HotKey(key: .one, modifiers: [.command, .option])
        hotKey?.keyDownHandler = {
            Task {
                do {
                    try await swapMainDisplay()
                } catch {
                    print("디스플레이 스왑 실패: \(error)")
                }
            }
        }
    }
    
    func updateHotKey(key: Key, modifiers: NSEvent.ModifierFlags) {
        hotKey = HotKey(key: key, modifiers: modifiers)
        hotKey?.keyDownHandler = {
            Task {
                do {
                    try await swapMainDisplay()
                } catch {
                    print("디스플레이 스왑 실패: \(error)")
                }
            }
        }
        NotificationCenter.default.post(name: HotKeyManager.hotKeyChangedNotification, object: nil)
    }
    
    func currentHotKeyDescription() -> String {
        guard let hotKey = hotKey else { return "⌘ + ⌥ + 1" }
        let keyCombo = hotKey.keyCombo
        var parts: [String] = []
        
        if keyCombo.modifiers.contains(.command) { parts.append("⌘") }
        if keyCombo.modifiers.contains(.option) { parts.append("⌥") }
        if keyCombo.modifiers.contains(.shift) { parts.append("⇧") }
        if keyCombo.modifiers.contains(.control) { parts.append("⌃") }
        
        if let key = keyCombo.key {
            parts.append(key.description)
        } else {
            parts.append("?")
        }
        return parts.joined(separator: " + ")
    }
}
