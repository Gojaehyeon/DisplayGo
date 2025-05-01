//
//  DisplayGoApp.swift
//  DisplayGo
//
//  Created by 고재현 on 4/30/25.
//

import SwiftUI
import AppKit

@main
struct DisplayGoApp: App {
    @StateObject private var shortcutManager = ShortcutManager()
    @State private var showMainWindow = true
    @State private var showInputMonitoringAlert = false
    
    init() {
        // 앱 시작 시 입력 모니터링 권한 확인
        let trusted = CGPreflightListenEventAccess()
        if !trusted {
            CGRequestListenEventAccess()
        }
    }
    
    var body: some Scene {
        MenuBarExtra("DisplayGo", systemImage: "display") {
            MenuBarView()
                .environmentObject(shortcutManager)
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup {
            if showMainWindow {
                ContentView()
                    .environmentObject(shortcutManager)
                    .alert("입력 모니터링 권한 필요", isPresented: $showInputMonitoringAlert) {
                        Button("설정 열기") {
                            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
                            NSWorkspace.shared.open(url)
                        }
                        Button("취소", role: .cancel) { }
                    } message: {
                        Text("DisplayGo가 단축키를 감지하기 위해서는 입력 모니터링 권한이 필요합니다.")
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            let trusted = CGPreflightListenEventAccess()
                            showInputMonitoringAlert = !trusted
                        }
                        if shortcutManager.shortcut.isEmpty {
                            NSApp.setActivationPolicy(.regular)
                            showMainWindow = true
                        } else {
                            showMainWindow = false
                        }
                        // 전역 모니터링 시작
                        shortcutManager.startGlobalMonitoring()
                    }
            }
        }
    }
}
