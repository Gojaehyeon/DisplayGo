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
