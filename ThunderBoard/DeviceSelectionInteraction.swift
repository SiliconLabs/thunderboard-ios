//
//  DeviceSelectionInteraction.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol DeviceSelectionInteractionOutput : class {
    
    // power
    func bleEnabled(_ enabled: Bool)
    
    // scanning
    func bleScanning(_ scanning: Bool)
    func bleScanningListUpdated()
    func bleDeviceUpdated(_ device: DiscoveredDeviceDisplay, index: Int)
    
    // connection
    func interactionShowConnectionInProgress(_ index: Int)
    func interactionShowConnectionTimedOut(_ deviceName: String)
    func interactionShowConnectionDemos(_ configuration: DemoConfiguration)
}

struct DiscoveredDeviceDisplay {
    var name: String
    var RSSI: Int?
    var connecting: Bool
}

struct DiscoveredDevice {
    let device: Device
    let latestDiscovery: Date
}

class DeviceSelectionInteraction : DeviceScannerDelegate, DeviceConnectionDelegate {
    
    fileprivate var deviceScanner: DeviceScanner?
    fileprivate var deviceConnector: DeviceConnection?
    fileprivate var interactionOutput: DeviceSelectionInteractionOutput?
    fileprivate var discoveredDevices = Array<DiscoveredDevice>()
    
    fileprivate var autoConnectDeviceName: String?
    fileprivate var abandonAutoConnectTimer: WeakTimer?
    fileprivate var expiredDiscoveryTimer: WeakTimer?
    fileprivate let expirationDuration: TimeInterval = 10
    fileprivate let updateThrottle = Throttle(interval: 0.75)
    
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
    
    func automaticallyConnectToDevice(_ identifier: String) {
        log.info("\(identifier)")
        setupAutoConnection(identifier)
    }
    
    func connectToDevice(_ index: Int) {
        if index < self.discoveredDevices.count {
            self.deviceConnector?.connect(self.discoveredDevices[index].device)
            self.interactionOutput?.interactionShowConnectionInProgress(index)
            
            abandonAutoConnectionDevice()
        }
    }
    
    func connectToDevice(_ device: Device) {
        if let index = self.discoveredDevices.index(where: { $0.device.deviceIdentifier == device.deviceIdentifier }) {
            connectToDevice(index)
        }
    }
    
    func numberOfDevices() -> Int {
        return self.discoveredDevices.count
    }
    
    func deviceAtIndex(_ index: Int) -> DiscoveredDeviceDisplay? {
        if self.discoveredDevices.count > index {
            let device = self.discoveredDevices[index].device
            return DiscoveredDeviceDisplay(name: device.displayName(), RSSI: device.RSSI, connecting: device.connectionState == .connecting)
        }
        return nil
    }
    
    func showSettings() {
        settingsPresenter?.showSettings()
    }
    
    //MARK:- Internal
    
    fileprivate func notifyPowerState(_ state: DeviceTransportState) {
        switch (state) {
        case .disabled:
            self.interactionOutput?.bleEnabled(false)
        case .enabled:
            self.interactionOutput?.bleEnabled(true)
        }
    }
    
    fileprivate func clearDeviceList() {
        self.discoveredDevices.removeAll()
    }
    
    fileprivate func indexOfDevice(_ device: Device) -> Int {

        for (index, d) in self.discoveredDevices.enumerated() {
            // Note: cannot use .identifier here because it isn't populated until connection
            if d.device.name == device.name {
                return index
            }
        }
        
        return NSNotFound
    }
    
    fileprivate func expiredDiscoveryTask() {
        let validDevices = self.discoveredDevices.filter({
            let now = Date()
            let lastTime = now.timeIntervalSince($0.latestDiscovery)
            return lastTime < expirationDuration
        })

        let notify = self.discoveredDevices.count != validDevices.count
        defer { if notify { self.interactionOutput?.bleScanningListUpdated() } }
        
        self.discoveredDevices = validDevices
    }
    
    //MARK: - Internal (Auto Connection)
    
    fileprivate func setupAutoConnection(_ identifier: String) {
        autoConnectDeviceName = identifier
        abandonAutoConnectTimer = WeakTimer.scheduledTimer(5, repeats: false, action: { [weak self] () -> Void in
            log.info("Abandoning attempts to connect to \(identifier) - timeout")
            self?.abandonAutoConnectionDevice()
        })
        
        attemptAutoConnection()
    }
    
    fileprivate func attemptAutoConnection() {
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
    
    fileprivate func abandonAutoConnectionDevice() {
        autoConnectDeviceName = nil
        abandonAutoConnectTimer?.stop()
        abandonAutoConnectTimer = nil
    }
    
    //MARK:- DeviceScannerDelegate
    
    func transportPowerStateUpdated(_ state: DeviceTransportState) {

        notifyPowerState(state)
        
        switch (state) {
        case .disabled:
            stopScanning()
        case .enabled:
            startScanning()
        }
    }
    
    func startedScanning() {
        self.interactionOutput?.bleScanning(true)
    }
    
    func discoveredDevice(_ device: Device) {

        let index = indexOfDevice(device)
        let discovered = DiscoveredDevice(device: device, latestDiscovery: Date())
        
        if index == NSNotFound {
            discoveredDevices.append(discovered)
            interactionOutput?.bleScanningListUpdated()
        }
        else {
            if let display = deviceAtIndex(index) {
                discoveredDevices[index] = discovered
                updateThrottle.run({ 
                    self.interactionOutput?.bleDeviceUpdated(display, index: index)
                })
            }
        }

        attemptAutoConnection()
    }
    
    func stoppedScanning() {
        interactionOutput?.bleScanning(false)
    }
    
    //MARK:- DeviceConnectionDelegate
    
    func connectedToDevice(_ device: Device) {
        interactionOutput?.interactionShowConnectionDemos(device)
    }
    
    func connectionToDeviceFailed() {
        // NO-OP - presenter is also notified, and is responsible for this notification
    }
    
    func connectionToDeviceTimedOut(_ device: Device) {
        guard let name = device.name else {
            self.interactionOutput?.interactionShowConnectionTimedOut("")
            return
        }
        
        interactionOutput?.interactionShowConnectionTimedOut(name)
    }
}
