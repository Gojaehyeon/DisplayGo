//
//  HotKeyManager.swift
//  DisplayGo
//
//  Created by 고재현 on 5/17/25.
//

import Foundation
import HotKey
import AppKit

final class HotKeyManager {
    static let shared = HotKeyManager()

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
}