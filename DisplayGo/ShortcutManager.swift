import Foundation
import AppKit

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
        stopGlobalMonitoring() // 기존 모니터링 중지
        
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self = self else { return }
            
            // 현재 눌린 모든 modifier 키 확인
            let currentModifiers = event.modifierFlags.intersection([.control, .option, .command, .shift])
            
            // Control + Option이 눌려있는지 확인
            let hasRequiredModifiers = currentModifiers.contains(.control) && 
                                     currentModifiers.contains(.option) &&
                                     currentModifiers.intersection([.command, .shift]).isEmpty
            
            if event.type == .keyDown {
                let key = event.charactersIgnoringModifiers?.uppercased() ?? ""
                print("감지된 키: \(key), 모디파이어: \(currentModifiers)")
                
                if hasRequiredModifiers && key == "G" {
                    print("단축키 일치! 화면 전환 시도...")
                    Task { @MainActor in
                        do {
                            try await swapMainDisplay()
                        } catch {
                            print("화면 전환 실패: \(error.localizedDescription)")
                        }
                    }
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
    
    deinit {
        stopMonitoring()
        stopGlobalMonitoring()
    }
} 