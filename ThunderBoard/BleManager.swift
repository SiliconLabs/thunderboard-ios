//
//  BleManager.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import CoreBluetooth

//MARK:- Delegate Protocols

class BleManager: NSObject, CBCentralManagerDelegate, DeviceScanner, DeviceConnection {
    
    private let connectionTimeout: NSTimeInterval = 5
    private var expectingDisconnect = false

    private var central: CBCentralManager?
    private var powerState: DeviceTransportState = .Disabled {
        didSet {
            
            // notify power state delegates
            self.applicationDelegate?.transportPowerStateUpdated(powerState)
            self.scanningDelegate?.transportPowerStateUpdated(powerState)
            
            // notify implicit scanning behaviors
            switch(powerState){
            case .Disabled:
                self.scanningDelegate?.stoppedScanning()
            case .Enabled:
                break
            }
        }
    }
    weak var applicationDelegate: DeviceTransportApplicationDelegate?

    private var bleDevices: [NSUUID:BleDevice] = Dictionary<NSUUID, BleDevice>()

    //MARK: - Initialization
    
    override init() {
        super.init()
        
        let opts = [ CBCentralManagerOptionShowPowerAlertKey : true ]
        let queue = dispatch_queue_create("com.silabs.thunderboard.blequeue", DISPATCH_QUEUE_SERIAL)
        self.central = CBCentralManager(delegate: self, queue: queue, options: opts)
    }
    
    //MARK: - Public - Scanning
    
    weak var scanningDelegate: DeviceScannerDelegate? {
        didSet {
            // notify delegate of current power state
            scanningDelegate?.transportPowerStateUpdated(self.powerState)
        }
    }
    func startScanning() {
        if powerState == .Enabled {
            let services: [CBUUID]? = nil
            let options: [String: AnyObject]? = [ CBCentralManagerScanOptionAllowDuplicatesKey : true ]
            self.central?.scanForPeripheralsWithServices(services, options: options)
            self.scanningDelegate?.startedScanning()
        }
    }
    
    func stopScanning() {
        self.central?.stopScan()
        self.scanningDelegate?.stoppedScanning()
    }
    
    //MARK: - Public - Connecting
    
    weak var connectionDelegate: DeviceConnectionDelegate? {
        didSet {
            for peripheral in self.connectedPeripherals {
                self.notifyConnectedPeripheral(peripheral)
            }
        }
    }

    func connect(device: Device) {
        guard let device = device as? BleDevice else {
            fatalError()
        }
        
        if self.peripheralPendingConnection == nil {
            device.connectionState = .Connecting
            self.central?.connectPeripheral(device.cbPeripheral!, options: nil)
            self.startConnectionTimer()
        }
    }
    
    func isConnectedToDevice(device: Device) -> Bool {
        guard let device = device as? BleDevice else {
            fatalError()
        }
        
        let peripherals = self.connectedPeripherals
        return peripherals.contains(device.cbPeripheral)
    }
    
    func disconnectAllDevices() {
        
        expectingDisconnect = true
        let list = self.connectedPeripherals
        for device in list {
            self.central?.cancelPeripheralConnection(device)
        }
    }
    
    //MARK: Connection Timer
    private var connectionTimer: NSTimer?
    private func startConnectionTimer() {
        self.connectionTimer = NSTimer.scheduledTimerWithTimeInterval(connectionTimeout, target: self, selector: #selector(connectionTimeoutFired), userInfo: nil, repeats: false)
    }
    
    private func stopConnectionTimer() {
        self.connectionTimer?.invalidate()
        self.connectionTimer = nil
    }
    
    @objc func connectionTimeoutFired() {
        log.error("connection attempt to device timed out")

        self.stopConnectionTimer()
        
        if let pending = self.peripheralPendingConnection {
            let device = bleDeviceForPeripheral(pending)
            
            //
            // On some devices, centralManager:didDisconnectPeripheral: is sent
            // when cancelPeripheralConnection is sent to the central, even if not connected.
            // Sometimes the error is nil, and sometimes it isn't ¯\_(ツ)_/¯
            //
            // And on some other devices, centralManager:didFailToConnectPeripheral is sent.
            // Either way, we'd expect the disconnect event, so be prepared for it.
            //
            expectingDisconnect = true
            
            self.central?.cancelPeripheralConnection(pending)
            device.connectionState = .Disconnected
            device.RSSI = nil
            
            self.notifyConnectionTimedOut(pending)
        }
    }
    
    //MARK: Notifications
    
    private func notifyConnectedPeripheral(peripheral: CBPeripheral!) {
        let device = bleDeviceForPeripheral(peripheral)
        self.applicationDelegate?.transportConnectedToDevice(device)
        self.connectionDelegate?.connectedToDevice(device)
    }
    
    private func notifyDisconnectedPeripheral(peripheral: CBPeripheral!) {
        let device = bleDeviceForPeripheral(peripheral)
        self.applicationDelegate?.transportDisconnectedFromDevice(device)
    }
    
    private func notifyConnectionTimedOut(peripheral: CBPeripheral) {
        let device = bleDeviceForPeripheral(peripheral)
        self.connectionDelegate?.connectionToDeviceTimedOut(device)
    }
    
    private func notifyLostConnection(peripheral: CBPeripheral) {
        let device = bleDeviceForPeripheral(peripheral)
        self.applicationDelegate?.transportLostConnectionToDevice(device)
    }
    
    private func notifyLostAllConnections() {
        let peripherals = self.bleDevices.map( { return $0.1.cbPeripheral } )
        for peripheral in peripherals {
            notifyDisconnectedPeripheral(peripheral)
            notifyLostConnection(peripheral)
        }
    }
    
    //MARK:- Internal
    
    private func bleDeviceForPeripheral(peripheral: CBPeripheral) -> BleDevice {
        if let existing = self.bleDevices[peripheral.identifier] {
            return existing
        }
        
        let device = BleDevice(peripheral: peripheral)
        self.bleDevices[peripheral.identifier] = device
        
        return device
    }
    
    private var connectedPeripherals: [CBPeripheral] {
        return self.bleDevices.values.filter({
            let result = $0.connectionState == .Connected
            return result
        }).map({ $0.cbPeripheral })
    }
    
    private var peripheralPendingConnection: CBPeripheral? {
        get {
            return self.bleDevices.values.filter({
                let result = $0.connectionState == .Connecting
                return result
            }).map({ $0.cbPeripheral }).first
        }
    }
    
    //MARK:- CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {

        dispatch_main_sync {
            switch(central.state) {
            case .PoweredOn:
                self.powerState = .Enabled
                
            case .PoweredOff: fallthrough
            case .Resetting: fallthrough
            case .Unauthorized: fallthrough
            case .Unknown: fallthrough
            case .Unsupported:
                self.powerState = .Disabled
                self.stopScanning()
                self.notifyLostAllConnections()
            }
        }
    }

    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        // RSSI value 127 is Apple-reserved and indicates the RSSI value could not be read.
        if RSSI.integerValue != 127 {
            if isThunderboard(peripheral) {
                let device = bleDeviceForPeripheral(peripheral)
                device.RSSI = RSSI.integerValue
                
                dispatch_main_async {
                    self.scanningDelegate?.discoveredDevice(device)
                }
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        log.info("connected to \(peripheral)")

        let device = bleDeviceForPeripheral(peripheral)
        device.connectionState = .Connected
        self.stopConnectionTimer()
        
        dispatch_main_async {
            self.notifyConnectedPeripheral(peripheral)
        }
        
        expectingDisconnect = false
        
        delay(5) {
            peripheral.services?.forEach({ (service) in
                print("---------------------------------------------------")
                print("      Service: \(service.UUID.UUIDString) (\(service.UUID))")
                service.characteristics?.forEach({ (characteristic) in
                    print("          Characteristic: \(characteristic.UUID.UUIDString) properties \(characteristic.properties)")
                })
            })

        }
    }
    
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        log.error("failed connection to peripheral \(peripheral) error \(error)")
        
        let device = bleDeviceForPeripheral(peripheral)
        device.connectionState = .Disconnected
        self.stopConnectionTimer()
        
        if expectingDisconnect == false {
            dispatch_main_async {
                self.notifyConnectionTimedOut(peripheral)
            }
        }
    }
    

    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        log.info("disconnected from peripheral \(peripheral) error=\(error)")
        
        let device = bleDeviceForPeripheral(peripheral)
        device.connectionState = .Disconnected
        
        dispatch_main_async {
            self.notifyDisconnectedPeripheral(peripheral)
            
            // Typically, "expected" disconnects do not include an error. However, 
            // that has proven unreliable during QA, so we explicitly track expected disconnects
            if self.expectingDisconnect == false {
                self.notifyLostConnection(peripheral)
            }
        }
    }
    
    
}
