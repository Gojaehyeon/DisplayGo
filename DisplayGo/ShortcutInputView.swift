import SwiftUI
import AppKit

struct ShortcutInputView: View {
    @EnvironmentObject var shortcutManager: ShortcutManager
    @Environment(\.dismiss) var dismiss
    @State private var isRecording = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("단축키 설정")
                .font(.headline)
            
            HStack {
                Text("현재 단축키:")
                Text(shortcutManager.shortcut.isEmpty ? "설정되지 않음" : shortcutManager.shortcut)
                    .foregroundColor(shortcutManager.shortcut.isEmpty ? .gray : .blue)
            }
            
            if isRecording {
                Text("단축키를 입력하세요...")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            } else {
                Text("새로운 단축키를 설정하려면 버튼을 클릭하세요")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Button(isRecording ? "취소" : "단축키 설정") {
                if isRecording {
                    print("단축키 입력 취소")
                    shortcutManager.stopMonitoring()
                } else {
                    print("단축키 입력 시작")
                    shortcutManager.startMonitoring()
                }
                isRecording.toggle()
            }
            .keyboardShortcut(.return, modifiers: [])
            
            Button("닫기") {
                if isRecording {
                    shortcutManager.stopMonitoring()
                    isRecording = false
                }
                dismiss()
            }
        }
        .padding()
        .frame(width: 300, height: 200)
        .onAppear {
            print("ShortcutInputView가 나타났습니다.")
            print("현재 단축키: \(shortcutManager.shortcut)")
        }
        .onChange(of: shortcutManager.shortcut) { newValue in
            print("단축키가 변경되었습니다: \(newValue)")
            if isRecording {
                isRecording = false
                dismiss()
            }
        }
        .onDisappear {
            if isRecording {
                shortcutManager.stopMonitoring()
                isRecording = false
            }
        }
    }
} 
