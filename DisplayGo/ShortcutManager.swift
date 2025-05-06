import Foundation
import AppKit
import CoreGraphics

class ShortcutManager: ObservableObject {
    @Published var shortcut: String = ""
    private var localMonitor: Any?
    private var globalMonitor: Any?
    
    init() {
        loadShortcut()
        if shortcut.isEmpty {
            shortcut = "⌃ ⌥ G"
            saveShortcut()
        }
        startGlobalMonitoring()
    }
    
    private func loadShortcut() {
        if let savedShortcut = UserDefaults.standard.string(forKey: "DisplayGoShortcut") {
            self.shortcut = savedShortcut
        }
    }
    
    private func saveShortcut() {
        UserDefaults.standard.set(shortcut, forKey: "DisplayGoShortcut")
    }
    
    func startMonitoring() {
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleKeyEvent(event)
            return nil
        }
    }
    
    func stopMonitoring() {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        var modifiers: [String] = []
        
        if event.modifierFlags.contains(.command) { modifiers.append("⌘") }
        if event.modifierFlags.contains(.option) { modifiers.append("⌥") }
        if event.modifierFlags.contains(.shift) { modifiers.append("⇧") }
        if event.modifierFlags.contains(.control) { modifiers.append("⌃") }
        
        let key = event.charactersIgnoringModifiers?.uppercased() ?? ""
        
        if !modifiers.isEmpty && !key.isEmpty {
            shortcut = (modifiers + [key]).joined(separator: " ")
            saveShortcut()
            stopMonitoring()
        }
    }
    
    func startGlobalMonitoring() {
        print("전역 모니터링 시작")
        stopGlobalMonitoring()
        
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self = self else { return }
            
            if event.type == .keyDown {
                let currentModifiers = event.modifierFlags
                let key = event.charactersIgnoringModifiers?.uppercased() ?? ""
                
                print("키 다운 감지 - 키: \(key), 모디파이어: \(currentModifiers.rawValue)")
                
                if currentModifiers.contains(.control) && 
                   currentModifiers.contains(.option) && 
                   !currentModifiers.contains(.command) && 
                   !currentModifiers.contains(.shift) && 
                   key == "G" {
                    print("단축키 일치! 화면 전환 시도...")
                    self.swapMainDisplay()
                }
            }
        }
    }
    
    func stopGlobalMonitoring() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
    }
    
    private func swapMainDisplay() {
        let displays = NSScreen.screens
        guard displays.count > 1 else {
            print("외부 디스플레이가 연결되어 있지 않습니다.")
            return
        }
        
        // 현재 메인 디스플레이 찾기
        let currentMain = displays.first { $0.frame.origin == .zero }
        guard let currentMain = currentMain else { return }
        
        // 다음 디스플레이 찾기
        let currentIndex = displays.firstIndex(of: currentMain) ?? 0
        let nextIndex = (currentIndex + 1) % displays.count
        let nextDisplay = displays[nextIndex]
        
        // 디스플레이 설정 변경
        let displayID = CGMainDisplayID()
        let nextDisplayID = nextDisplay.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0
        
        if let displayMode = CGDisplayCopyDisplayMode(nextDisplayID) {
            CGDisplaySetDisplayMode(displayID, displayMode, nil)
            print("디스플레이 전환 완료: \(nextDisplayID)")
        }
    }
    
    deinit {
        stopMonitoring()
        stopGlobalMonitoring()
    }
} 
