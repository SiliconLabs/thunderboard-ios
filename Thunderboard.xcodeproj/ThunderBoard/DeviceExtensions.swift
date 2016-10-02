//
//  DeviceExtensions.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

extension Device {
    func ledColor(index: Int) -> LedStaticColor {
        // There isn't a way to query the Thunderboard devices for their LED
        // colors, so this is table for known configurations.
        switch self.model {
        case .React:
            return [ LedStaticColor.Blue, LedStaticColor.Green ][index]
        case .Sense:
            return [ LedStaticColor.Red, LedStaticColor.Green ][index]
        case .Unknown:
            return .Green
        }
    }
}