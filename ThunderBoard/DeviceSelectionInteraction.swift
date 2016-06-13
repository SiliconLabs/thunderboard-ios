//
//  DeviceSelectionInteraction.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol DeviceSelectionInteractionOutput : class {
    
    // power
    func bleEnabled(enabled: Bool)
    
    // scanning
    func bleScanning(scanning: Bool)
    func bleScanningListUpdated()
    func bleDeviceUpdated(device: DiscoveredDeviceDisplay, index: Int)
    
    // connection
    func interactionShowConnectionInProgress(index: Int)
    func interactionShowConnectionTimedOut(deviceName: String)
    func interactionShowConnectionDemos(configuration: DemoConfiguration)
}

struct DiscoveredDeviceDisplay {
    var name: String
    var RSSI: Int?
    var connecting: Bool
}

struct DiscoveredDevice {
    let device: Device
    let latestDiscovery: NSDate
}

class DeviceSelectionInteraction : DeviceScannerDelegate, DeviceConnectionDelegate {
    
    private var deviceScanner: DeviceScanner?
    private var deviceConnector: DeviceConnection?
    private var interactionOutput: DeviceSelectionInteractionOutput?
    private var discoveredDevices = Array<DiscoveredDevice>()
    
    private var autoConnectDeviceName: String?
    private var abandonAutoConnectTimer: WeakTimer?
    private var expiredDiscoveryTimer: WeakTimer?
    private let expirationDuration: NSTimeInterval = 10
    
    var settingsPresenter: SettingsPresenter?
    
    init(scanner: DeviceScanner, connector: DeviceConnection, interactionOutput: DeviceSelectionInteractionOutput) {
        
        self.interactionOutput = interactionOutput
        
        self.deviceScanner = scanner
        self.deviceScanner?.scanningDelegate = self
        
        self.deviceConnector = connector
        self.deviceConnector?.connectionDelegate = self
    }
    
    //MARK:- Public
    
    func startScanning() {
        self.deviceConnector?.disconnectAllDevices()
        self.deviceScanner?.startScanning()
        self.expiredDiscoveryTimer = WeakTimer.scheduledTimer(1, repeats: true, action: expiredDiscoveryTask)
    }
    
    func stopScanning() {
        self.deviceScanner?.stopScanning()
        self.clearDeviceList()
        self.expiredDiscoveryTimer = nil
    }
    
    func automaticallyConnectToDevice(identifier: String) {
        log.info("\(identifier)")
        setupAutoConnection(identifier)
    }
    
    func connectToDevice(index: Int) {
        if index < self.discoveredDevices.count {
            self.deviceConnector?.connect(self.discoveredDevices[index].device)
            self.interactionOutput?.interactionShowConnectionInProgress(index)
            
            abandonAutoConnectionDevice()
        }
    }
    
    func connectToDevice(device: Device) {
        if let index = self.discoveredDevices.indexOf({ $0.device.deviceIdentifier == device.deviceIdentifier }) {
            connectToDevice(index)
        }
    }
    
    func numberOfDevices() -> Int {
        return self.discoveredDevices.count
    }
    
    func deviceAtIndex(index: Int) -> DiscoveredDeviceDisplay? {
        if self.discoveredDevices.count > index {
            let device = self.discoveredDevices[index].device
            return DiscoveredDeviceDisplay(name: device.name!, RSSI: device.RSSI, connecting: device.connectionState == .Connecting)
        }
        
        return nil
    }
    
    func showSettings() {
        settingsPresenter?.showSettings()
    }
    
    //MARK:- Internal
    
    private func notifyPowerState(state: DeviceTransportState) {
        switch (state) {
        case .Disabled:
            self.interactionOutput?.bleEnabled(false)
        case .Enabled:
            self.interactionOutput?.bleEnabled(true)
        }
    }
    
    private func clearDeviceList() {
        self.discoveredDevices.removeAll()
    }
    
    private func indexOfDevice(device: Device) -> Int {

        for (index, d) in self.discoveredDevices.enumerate() {
            // Note: cannot use .identifier here because it isn't populated until connection
            if d.device.name == device.name {
                return index
            }
        }
        
        return NSNotFound
    }
    
    private func expiredDiscoveryTask() {
        let validDevices = self.discoveredDevices.filter({
            let now = NSDate()
            let lastTime = now.timeIntervalSinceDate($0.latestDiscovery)
            return lastTime < expirationDuration
        })

        let notify = self.discoveredDevices.count != validDevices.count
        defer { if notify { self.interactionOutput?.bleScanningListUpdated() } }
        
        self.discoveredDevices = validDevices
    }
    
    //MARK: - Internal (Auto Connection)
    
    private func setupAutoConnection(identifier: String) {
        autoConnectDeviceName = identifier
        abandonAutoConnectTimer = WeakTimer.scheduledTimer(5, repeats: false, action: { [weak self] () -> Void in
            log.info("Abandoning attempts to connect to \(identifier) - timeout")
            self?.abandonAutoConnectionDevice()
            })
        
        attemptAutoConnection()
    }
    
    private func attemptAutoConnection() {
        guard let name = autoConnectDeviceName else {
            return
        }
        
        log.debug("discovered devices: \(self.discoveredDevices)")
        guard let discovered = self.discoveredDevices.filter({ return $0.device.name == name }).first else {
            log.info("No discovered devices match pending auto-connect device")
            return
        }
        
        guard let connector = self.deviceConnector else {
            log.error("No device connector available")
            return
        }
        
        if connector.isConnectedToDevice(discovered.device) {
            log.info("already connected to \(name), ignoring auto-connect request")
            abandonAutoConnectionDevice()
        }
        else {
            log.info("Attempting auto connection to device \(name)")
            self.connectToDevice(discovered.device)
        }
    }
    
    private func abandonAutoConnectionDevice() {
        autoConnectDeviceName = nil
        abandonAutoConnectTimer?.stop()
        abandonAutoConnectTimer = nil
    }
    
    //MARK:- DeviceScannerDelegate
    
    func transportPowerStateUpdated(state: DeviceTransportState) {

        notifyPowerState(state)
        
        switch (state) {
        case .Disabled:
            stopScanning()
        case .Enabled:
            startScanning()
        }
    }
    
    func startedScanning() {
        self.interactionOutput?.bleScanning(true)
    }
    
    func discoveredDevice(device: Device) {

        let index = indexOfDevice(device)
        let discovered = DiscoveredDevice(device: device, latestDiscovery: NSDate())
        
        if index == NSNotFound {
            self.discoveredDevices.append(discovered)
            self.interactionOutput?.bleScanningListUpdated()
        }
        else {
            if let display = deviceAtIndex(index) {
                self.discoveredDevices[index] = discovered
                self.interactionOutput?.bleDeviceUpdated(display, index: index)
            }
        }

        attemptAutoConnection()
    }
    
    func stoppedScanning() {
        self.interactionOutput?.bleScanning(false)
    }
    
    //MARK:- DeviceConnectionDelegate
    
    func connectedToDevice(device: Device) {
        self.interactionOutput?.interactionShowConnectionDemos(device.demoConfiguration())
    }
    
    func connectionToDeviceFailed() {
        // NO-OP - presenter is also notified, and is responsible for this notification
    }
    
    func connectionToDeviceTimedOut(device: Device) {
        guard let name = device.name else {
            self.interactionOutput?.interactionShowConnectionTimedOut("")
            return
        }
        
        self.interactionOutput?.interactionShowConnectionTimedOut(name)
    }
}