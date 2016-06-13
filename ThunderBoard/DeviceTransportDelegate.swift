//
//  DeviceTransportDelegate.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

enum DeviceTransportState {
    case Enabled
    case Disabled
}

protocol DeviceTransportPowerDelegate: class {
    func transportPowerStateUpdated(state: DeviceTransportState)
}

protocol DeviceTransportApplicationDelegate: DeviceTransportPowerDelegate {
    func transportConnectedToDevice(device: Device)
    func transportDisconnectedFromDevice(device: Device)
    func transportLostConnectionToDevice(device: Device)
}
