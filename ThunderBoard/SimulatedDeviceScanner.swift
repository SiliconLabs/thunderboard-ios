//
//  SimulatedDeviceScanner.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class SimulatedDeviceScanner : DeviceScanner, DeviceConnection {
    
    init() {
        delay(1) {
            // simulate delayed Bluetooth initialization
            self.powerState = .Enabled
        }
        
//        delay(5) {
//            // simulate disabling Bluetooth
//            self.powerState = .Disabled
//        }
//        
//        delay(7) {
//            // simulate disabling Bluetooth
//            self.powerState = .Enabled
//        }
    }
    
    //MARK: - Runtime Configuration
    let numberDevicesFound = 1
    
    //MARK: - Simulated API
    
    func simulateLostConnection(device: SimulatedDevice) {
        device.connectionState = .Disconnected
        self.applicationDelegate?.transportLostConnectionToDevice(device)
    }
    
    //MARK: - DeviceScanner
    
    var scanningDelegate: DeviceScannerDelegate?
    func startScanning() {
        if powerState == .Enabled {
            scanningDelegate?.startedScanning()
            simulateDiscoveredDevice()
        }
    }
    
    func stopScanning() {
        scanningDelegate?.stoppedScanning()
    }
    
    //MARK: - DeviceConnection
    
    weak var connectionDelegate: DeviceConnectionDelegate?
    var currentDevice: Device?
    func connect(device: Device) {
        currentDevice = device
        device.connectionState = .Connecting

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            
            device.connectionState = .Connected
            self.connectionDelegate?.connectedToDevice(device)
            self.applicationDelegate?.transportConnectedToDevice(device)
        }
    }
    
    func isConnectedToDevice(device: Device) -> Bool {
        guard let current = currentDevice else {
            return false
        }
        
        return current.deviceIdentifier == device.deviceIdentifier
    }
    
    func disconnectAllDevices() {
        if let device = currentDevice {
            self.applicationDelegate?.transportDisconnectedFromDevice(device)
        }
        
        self.currentDevice = nil
    }
    
    //MARK: - Bluetooth Simulation
    
    weak var applicationDelegate: DeviceTransportApplicationDelegate? {
        didSet {
            notifyDelegates()
        }
    }
    
    private var powerState: DeviceTransportState = .Disabled {
        didSet {
            
            notifyDelegates()
            
            // notify implicit scanning behaviors
            switch(powerState){
            case .Disabled:
                stopScanning()
                
            case .Enabled:
                break
            }
        }
    }

    //MARK: - Internal
    
    private func notifyDelegates() {
        self.applicationDelegate?.transportPowerStateUpdated(powerState)
        self.scanningDelegate?.transportPowerStateUpdated(powerState)
    }
    
    private func simulateDiscoveredDevice() {
        
        for i in 0..<numberDevicesFound {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 + (Double(i) * 0.7) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                
                let device = SimulatedDevice()
                device.name = "Thunder React #0005877\(i)"
                device.deviceIdentifier = DeviceId(i)
                device.simulatedScanner = self
                self.scanningDelegate?.discoveredDevice(device)
            }
        }

    }
}
