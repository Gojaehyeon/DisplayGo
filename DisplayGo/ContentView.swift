//
//  ContentView.swift
//  DisplayGo
//
//  Created by 고재현 on 4/30/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var shortcutManager: ShortcutManager
    @Environment(\.dismiss) private var dismiss
    @State private var isRecording = false

    var body: some View {
        VStack(spacing: 20) {
            Text("DisplayGo")
                .font(.largeTitle)
                .padding(.top)
            
            VStack(spacing: 15) {
                Text("현재 단축키")
                    .font(.headline)
                
                Text(shortcutManager.shortcut.isEmpty ? "설정되지 않음" : shortcutManager.shortcut)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(shortcutManager.shortcut.isEmpty ? .gray : .primary)
                    .padding(.vertical, 5)
                
            Button(action: {
                    isRecording.toggle()
            }) {
                    Text(isRecording ? "녹화 중... (키를 누르세요)" : "새 단축키 설정")
                        .frame(width: 200)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRecording)
            }
                    .padding()
            .background(Color(.windowBackgroundColor))
            .cornerRadius(10)
            
            Button("닫기") {
                if isRecording {
                    shortcutManager.stopMonitoring()
                    isRecording = false
                }
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}
