//
//  DeviceScanner.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol DeviceScanner: class {
    weak var scanningDelegate: DeviceScannerDelegate? { get set }
    
    func startScanning()
    func stopScanning()
}

protocol DeviceScannerDelegate: DeviceTransportPowerDelegate {
    func startedScanning()
    func discoveredDevice(_ device: Device)
    func stoppedScanning()
}
