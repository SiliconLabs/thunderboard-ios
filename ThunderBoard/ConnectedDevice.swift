//
//  ConnectedDevice.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol ConnectedDeviceDelegate: class {
    func connectedDeviceUpdated(_ name: String, RSSI: Int?, power: PowerSource, identifier: DeviceId?, firmwareVersion: String?)
}
