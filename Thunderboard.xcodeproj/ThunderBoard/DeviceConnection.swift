//
//  BleConnection.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol DeviceConnection: class {
    weak var connectionDelegate: DeviceConnectionDelegate? { get set }
    func connect(device: Device)
    func disconnectAllDevices()
    func isConnectedToDevice(device: Device) -> Bool
}

protocol DeviceConnectionDelegate: class {
    func connectedToDevice(device: Device)
    func connectionToDeviceTimedOut(device: Device)
    func connectionToDeviceFailed()
}