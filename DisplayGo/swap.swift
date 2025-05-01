//
//  swap.swift
//  DisplayGo
//
//  Created by 고재현 on 4/30/25.
//

import Foundation
import CoreGraphics
import AppKit

enum DisplaySwapError: Error {
    case noDisplays
    case singleDisplay
    case configurationFailed
}

public func swapMainDisplay() async throws {
    var displayCount: UInt32 = 0
    CGGetActiveDisplayList(0, nil, &displayCount)
    guard displayCount > 0 else { throw DisplaySwapError.noDisplays }

    var displays = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
    CGGetActiveDisplayList(displayCount, &displays, nil)
    guard displays.count >= 2 else { throw DisplaySwapError.singleDisplay }

    let display1 = displays[0]
    let display2 = displays[1]

    let bounds1 = CGDisplayBounds(display1)
    let bounds2 = CGDisplayBounds(display2)

    let zeroDisplay = (bounds1.origin == .zero) ? display1 : display2
    let nonZeroDisplay = (bounds1.origin == .zero) ? display2 : display1

    let relativeX = Int32(CGDisplayBounds(nonZeroDisplay).origin.x - CGDisplayBounds(zeroDisplay).origin.x)
    let relativeY = Int32(CGDisplayBounds(nonZeroDisplay).origin.y - CGDisplayBounds(zeroDisplay).origin.y)

    var config: CGDisplayConfigRef?
    CGBeginDisplayConfiguration(&config)
    CGConfigureDisplayOrigin(config, nonZeroDisplay, 0, 0)
    CGConfigureDisplayOrigin(config, zeroDisplay, -relativeX, -relativeY)

    let result = CGCompleteDisplayConfiguration(config, .permanently)
    guard result == .success else { throw DisplaySwapError.configurationFailed }
}

class DisplayManager {
    static let shared = DisplayManager()
    
    private init() {}
    
    func swapMainDisplay() throws {
        // 활성 디스플레이 목록 가져오기
        var displayCount: UInt32 = 0
        CGGetActiveDisplayList(0, nil, &displayCount)
        
        var displays = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
        CGGetActiveDisplayList(displayCount, &displays, nil)
        
        print("감지된 디스플레이: \(displays)")
        
        if displays.count >= 2 {
            // 두 디스플레이의 현재 위치 가져오기
            let display1 = displays[0]
            let display2 = displays[1]
            
            let bounds1 = CGDisplayBounds(display1)
            let bounds2 = CGDisplayBounds(display2)
            
            // (0,0)이 아닌 디스플레이 찾기
            let nonZeroDisplay = (bounds1.origin.x == 0 && bounds1.origin.y == 0) ? display2 : display1
            let zeroDisplay = (bounds1.origin.x == 0 && bounds1.origin.y == 0) ? display1 : display2
            
            let nonZeroBounds = (bounds1.origin.x == 0 && bounds1.origin.y == 0) ? bounds2 : bounds1
            let zeroBounds = (bounds1.origin.x == 0 && bounds1.origin.y == 0) ? bounds1 : bounds2
            
            // 상대적 위치 계산
            let relativeX = Int32(nonZeroBounds.origin.x - zeroBounds.origin.x)
            let relativeY = Int32(nonZeroBounds.origin.y - zeroBounds.origin.y)
            
            // 디스플레이 설정 변경
            var config: CGDisplayConfigRef?
            CGBeginDisplayConfiguration(&config)
            
            // (0,0)이 아닌 디스플레이를 (0,0)으로 이동
            CGConfigureDisplayOrigin(config, nonZeroDisplay, 0, 0)
            
            // 원래 (0,0)이었던 디스플레이를 상대적 위치의 반대 방향으로 이동
            CGConfigureDisplayOrigin(config, zeroDisplay, -relativeX, -relativeY)
            
            // 설정 적용
            CGCompleteDisplayConfiguration(config, .permanently)
            
            print("디스플레이 위치가 교환되었습니다.")
        } else {
            print("디스플레이가 2개 이상 필요합니다.")
            throw NSError(domain: "DisplayManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "디스플레이가 2개 이상 필요합니다."])
        }
    }
}
