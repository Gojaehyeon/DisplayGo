import Cocoa

final class KeyboardMonitor {
    static func start() {
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: { _, _, event, _ in
                return Unmanaged.passUnretained(event) // nil 대신 event 반환
            },
            userInfo: nil
        ) else {
            print("⚠️ 이벤트 탭 생성 실패. 입력 모니터링 권한이 없을 수 있습니다.")
            return
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        print("⌨️ 입력 이벤트 감시 시작됨.")
        simulateKeyInput()
    }

    private static func simulateKeyInput() {
        let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false)
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
        print("🧪 가짜 키보드 입력 시도됨.")
    }
}
