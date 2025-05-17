//
//  KeyCaptureWindowController.swift
//  DisplayGo
//
//  Created by 고재현 on 5/17/25.
//



import Cocoa
import HotKey

class HotKeyPopoverViewController: NSViewController {
    private let currentHotKeyLabel = NSTextField(labelWithString: "")
    private let changeButton = NSButton(title: "변경", target: nil, action: nil)
    private let saveButton = NSButton(title: "저장", target: nil, action: nil)
    private var keyMonitor: Any?
    private let isKorean = Locale.preferredLanguages.first?.hasPrefix("ko") == true
    private var currentHotKeyPrefix: String { isKorean ? "현재 단축키: " : "Current Hotkey: " }
    private var changeButtonTitle: String { isKorean ? "변경" : "Change" }
    private var saveButtonTitle: String { isKorean ? "저장" : "Save" }
    private var inputGuideText: String { isKorean ? "새 단축키를 입력하세요..." : "Enter new hotkey..." }

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 240, height: 120))
        
        // 라벨 중앙 정렬
        currentHotKeyLabel.alignment = .center
        currentHotKeyLabel.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        currentHotKeyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 버튼 스타일 및 중앙 정렬
        changeButton.setButtonType(.momentaryPushIn)
        saveButton.setButtonType(.momentaryPushIn)
        changeButton.font = NSFont.systemFont(ofSize: 13)
        saveButton.font = NSFont.systemFont(ofSize: 13)
        changeButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        changeButton.title = changeButtonTitle
        saveButton.title = saveButtonTitle
        
        // 버튼 그룹 StackView
        let buttonStack = NSStackView(views: [changeButton, saveButton])
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 16
        buttonStack.alignment = .centerX
        buttonStack.distribution = .equalCentering
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        // 전체 StackView
        let mainStack = NSStackView(views: [currentHotKeyLabel, buttonStack])
        mainStack.orientation = .vertical
        mainStack.spacing = 18
        mainStack.alignment = .centerX
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
        
        updateHotKeyLabel()
        changeButton.target = self
        changeButton.action = #selector(beginKeyCapture)
        saveButton.target = self
        saveButton.action = #selector(saveHotKey)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(hotKeyChanged), name: HotKeyManager.hotKeyChangedNotification, object: nil)
    }

    private func updateHotKeyLabel() {
        currentHotKeyLabel.stringValue = currentHotKeyPrefix + HotKeyManager.shared.currentHotKeyDescription()
        currentHotKeyLabel.alignment = .center
    }

    @objc private func beginKeyCapture() {
        currentHotKeyLabel.stringValue = inputGuideText
        currentHotKeyLabel.alignment = .center
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            if let monitor = self.keyMonitor {
                NSEvent.removeMonitor(monitor)
                self.keyMonitor = nil
            }

            if let key = Key(carbonKeyCode: UInt32(event.keyCode)) {
                let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
                HotKeyManager.shared.updateHotKey(key: key, modifiers: modifiers)
                self.updateHotKeyLabel()
            } else {
                self.currentHotKeyLabel.stringValue = self.isKorean ? "지원하지 않는 키입니다. 다시 시도하세요." : "Unsupported key. Try again."
            }

            return nil
        }
    }

    @objc private func saveHotKey() {
        print("💾 단축키 저장됨")
        self.view.window?.close()
    }

    @objc private func hotKeyChanged() {
        updateHotKeyLabel()
    }
}
