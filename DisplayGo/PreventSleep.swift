import Foundation
import IOKit.pwr_mgt
import AppKit
import SwiftUI

class PreventSleepManager: NSObject, ObservableObject {
    @Published var isPreventingSleep = false
    @Published var selectedDuration: TimeInterval?
    private var assertionID: IOPMAssertionID = 0
    private var displaySleepAssertionID: IOPMAssertionID = 0
    var timer: Timer?
    
    enum Duration: CaseIterable {
        case off
        case minutes15
        case minutes30
        case minutes45
        case hour1
        case hours4
        case hours8
        case infinite
        
        var minutes: Int {
            switch self {
            case .off: return 0
            case .minutes15: return 15
            case .minutes30: return 30
            case .minutes45: return 45
            case .hour1: return 60
            case .hours4: return 240
            case .hours8: return 480
            case .infinite: return 0
            }
        }
        
        var seconds: TimeInterval? {
            switch self {
            case .infinite:
                return nil
            default:
                return TimeInterval(minutes * 60)
            }
        }
        
        var displayString: String {
            switch self {
            case .off: return "off"
            case .minutes15: return "15"
            case .minutes30: return "30"
            case .minutes45: return "45"
            case .hour1: return "1h"
            case .hours4: return "4h"
            case .hours8: return "8h"
            case .infinite: return "∞"
            }
        }
    }
    
    func toggleSleepPrevention(duration: Duration? = nil) {
        if isPreventingSleep {
            disableSleepPrevention()
        } else {
            enableSleepPrevention(duration: duration)
        }
        updateStatusBarIcon()
    }
    
    func enableSleepPrevention(duration: Duration? = nil) {
        var assertionID = IOPMAssertionID(0)
        let reason = "DisplayGo: Keep system awake" as CFString
        var displaySleepAssertionID = IOPMAssertionID(0)
        let resultDisplay = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &displaySleepAssertionID
        )
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )
        
        if result == kIOReturnSuccess {
            self.assertionID = assertionID
            self.displaySleepAssertionID = displaySleepAssertionID
            self.isPreventingSleep = true
            
            if let duration = duration, let seconds = duration.seconds {
                self.selectedDuration = seconds
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
                    self?.disableSleepPrevention()
                }
            } else {
                self.selectedDuration = nil
            }
        }
        updateStatusBarIcon()
    }
    
    func disableSleepPrevention() {
        if isPreventingSleep {
            IOPMAssertionRelease(assertionID)
            IOPMAssertionRelease(displaySleepAssertionID)
            isPreventingSleep = false
            selectedDuration = nil
            timer?.invalidate()
            timer = nil
        }
        updateStatusBarIcon()
    }
    
    private func updateStatusBarIcon() {
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate,
           let button = appDelegate.statusItem?.button {
            let imageName = isPreventingSleep ? "display.and.arrow.down" : "display"
            let image = NSImage(systemSymbolName: imageName, accessibilityDescription: "DisplayGo")
            image?.isTemplate = true
            button.image = image
        }
    }
    
    deinit {
        disableSleepPrevention()
    }
}

struct PreventSleepView: View {
    @ObservedObject private var sleepManager: PreventSleepManager
    private let isKorean = Locale.preferredLanguages.first?.hasPrefix("ko") == true
    
    init(sleepManager: PreventSleepManager) {
        self.sleepManager = sleepManager
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prevent Sleep")
                .foregroundColor(.primary)
                .font(.system(size: 13))
                .padding(.horizontal, 16)
            HStack(spacing: 5) {
                ForEach(PreventSleepManager.Duration.allCases, id: \.self) { duration in
                    Button(action: {
                        if duration == .off {
                            sleepManager.disableSleepPrevention()
                        } else {
                            sleepManager.enableSleepPrevention(duration: duration)
                        }
                    }) {
                        Text(duration.displayString)
                            .font(.system(size: 12))
                            .frame(width: 26, height: 26)
                            .foregroundColor(getButtonTextColor(for: duration))
                            .background(
                                Circle()
                                    .fill(getButtonBackgroundColor(for: duration))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
        .padding(.top, -8)
    }
    
    private func getButtonTextColor(for duration: PreventSleepManager.Duration) -> Color {
        if duration == .off {
            return !sleepManager.isPreventingSleep ? .white : .primary
        }
        return (sleepManager.isPreventingSleep &&
                ((duration == .infinite && sleepManager.selectedDuration == nil) ||
                 (duration != .infinite && sleepManager.selectedDuration == duration.seconds)))
               ? .white : .primary
    }
    
    private func getButtonBackgroundColor(for duration: PreventSleepManager.Duration) -> Color {
        if duration == .off {
            return !sleepManager.isPreventingSleep ? .red : Color(.unemphasizedSelectedContentBackgroundColor)
        }
        return (sleepManager.isPreventingSleep &&
                ((duration == .infinite && sleepManager.selectedDuration == nil) ||
                 (duration != .infinite && sleepManager.selectedDuration == duration.seconds)))
               ? .accentColor : Color(.unemphasizedSelectedContentBackgroundColor)
    }
}
