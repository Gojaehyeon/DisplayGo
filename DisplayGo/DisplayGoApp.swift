import SwiftUI

@main
struct DisplayGoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {} // 메뉴바 앱이기 때문에 비워둠
    }
}
