//
//  SimulatedDeviceScanner.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class SimulatedDeviceScanner : DeviceScanner, DeviceConnection {
    
    private var discoveryTimer: WeakTimer?
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
            discoveryTimer = WeakTimer.scheduledTimer(0.1, repeats: true, action: { [weak self] in
                self?.simulateDiscoveredDevice()
            })
        }
    }
    
    func stopScanning() {
        discoveryTimer = nil
        scanningDelegate?.stoppedScanning()
    }
    
    //MARK: - DeviceConnection
    
    weak var connectionDelegate: DeviceConnectionDelegate?
    var currentDevice: Device?
    func connect(device: Device) {
        guard let device = device as? SimulatedDevice else {
            fatalError()
        }
        
        currentDevice = device
        device.connectionState = .Connecting

        delay(0.8) {
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
    
    private lazy var discoveredDevices: [SimulatedDevice] = {
        let reactCapabilities: Set<DeviceCapability> = [
            .Temperature,
            .Humidity,
            .AmbientLight,
            .UVIndex,
        ]
        
        let senseCapabilities: Set<DeviceCapability> = [
            .Temperature,
            .Humidity,
            .AmbientLight,
            .UVIndex,
            .AirQualityCO2,
            .AirQualityVOC,
            .AirPressure,
            .SoundLevel,
            .RGBOutput,
        ]
        
        let devices: [SimulatedDevice] = [
            SimulatedDevice(name: "Thunderboard-React #58771", identifier: DeviceId(1), capabilities: reactCapabilities),
            SimulatedDevice(name: "Thunderboard-Sense #58772", identifier: DeviceId(2), capabilities: senseCapabilities, model: .Sense),
        ]
        
        return devices
    }()
    
    private func simulateDiscoveredDevice() {
        discoveredDevices.forEach({
            $0.simulatedScanner = self
            $0.RSSI = (-1 * Int(rand()) % 100)
            self.scanningDelegate?.discoveredDevice($0)
        })
    }
}
