import SwiftUI
import AppKit

class MenuBarViewModel: ObservableObject {
    @Published var isActive = false
    @Published var showSettings = false
}

struct MenuBarView: View {
    @StateObject private var viewModel = MenuBarViewModel()
    @EnvironmentObject private var shortcutManager: ShortcutManager
    @State private var showShortcutSettings = false
    @State private var showInputMonitoringAlert = false
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                swapDisplays()
            }) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("화면 전환")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack {
                Image(systemName: "keyboard")
                Text("단축키: ⌃ ⌥ G")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.gray)
            
            Divider()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                    Text("종료")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(width: 160)
        .alert("입력 모니터링 권한 필요", isPresented: $showInputMonitoringAlert) {
            Button("설정 열기") {
                openInputMonitoringPreferences()
            }
            Button("취소", role: .cancel) {
                viewModel.isActive = false
            }
        } message: {
            Text("DisplayGo가 단축키를 감지하기 위해서는 입력 모니터링 권한이 필요합니다.")
        }
        .onAppear {
            checkInputMonitoringPermission()
            shortcutManager.startGlobalMonitoring()
        }
        .onDisappear {
            shortcutManager.stopGlobalMonitoring()
        }
    }
    
    private func checkInputMonitoringPermission() {
        let trusted = CGPreflightListenEventAccess()
        if !trusted {
            showInputMonitoringAlert = true
            viewModel.isActive = false
            CGRequestListenEventAccess()
        } else {
            viewModel.isActive = true
        }
    }
    
    private func openInputMonitoringPreferences() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
    }
    
    private func swapDisplays() {
        Task {
            do {
                try await swapMainDisplay()
            } catch {
                print("화면 전환 실패: \(error.localizedDescription)")
            }
        }
    }
} 
