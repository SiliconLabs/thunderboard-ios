//
//  Device.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

enum DeviceConnectionState {
    case Disconnected
    case Connecting
    case Connected
}

typealias DeviceId = UInt64
extension DeviceId {
    func toString() -> String {
        return "\(self)"
    }
}

protocol Device : class {
    var name: String? { get }
    var deviceIdentifier: DeviceId? { get }
    var RSSI: Int? { get }
    var batteryLevel: Int? { get }
    var firmwareVersion: String? { get }
    var connectionState: DeviceConnectionState { get set }
    weak var connectedDelegate: ConnectedDeviceDelegate? { get set }

    func demoConfiguration() -> DemoConfiguration
}