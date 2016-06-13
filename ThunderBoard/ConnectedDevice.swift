//
//  ConnectedDevice.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol ConnectedDeviceDelegate: class {
    func connectedDeviceUpdated(name: String, RSSI: Int?, battery: Int?, identifier: DeviceId?, firmwareVersion: String?)
}