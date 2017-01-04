//
//  BleManager.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import CoreBluetooth

//MARK:- Delegate Protocols

class BleManager: NSObject, CBCentralManagerDelegate, DeviceScanner, DeviceConnection {
    
    fileprivate let connectionTimeout: TimeInterval = 5
    fileprivate var expectingDisconnect = false

    fileprivate var central: CBCentralManager?
    fileprivate var powerState: DeviceTransportState = .disabled {
        didSet {
            
            // notify power state delegates
            self.applicationDelegate?.transportPowerStateUpdated(powerState)
            self.scanningDelegate?.transportPowerStateUpdated(powerState)
            
            // notify implicit scanning behaviors
            switch(powerState){
            case .disabled:
                self.scanningDelegate?.stoppedScanning()
            case .enabled:
                break
            }
        }
    }
    weak var applicationDelegate: DeviceTransportApplicationDelegate?

    fileprivate var bleDevices: [UUID:BleDevice] = Dictionary<UUID, BleDevice>()

    //MARK: - Initialization
    
    override init() {
        super.init()
        
        let opts = [ CBCentralManagerOptionShowPowerAlertKey : true ]
        let queue = DispatchQueue(label: "com.silabs.thunderboard.blequeue", attributes: [])
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
        if powerState == .enabled {
            let services: [CBUUID]? = nil
            let options: [String: AnyObject]? = [ CBCentralManagerScanOptionAllowDuplicatesKey : true as AnyObject ]
            self.central?.scanForPeripherals(withServices: services, options: options)
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

    func connect(_ device: Device) {
        guard let device = device as? BleDevice else {
            fatalError()
        }
        
        if self.peripheralPendingConnection == nil {
            device.connectionState = .connecting
            self.central?.connect(device.cbPeripheral!, options: nil)
            self.startConnectionTimer()
        }
    }
    
    func isConnectedToDevice(_ device: Device) -> Bool {
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
    fileprivate var connectionTimer: Timer?
    fileprivate func startConnectionTimer() {
        self.connectionTimer = Timer.scheduledTimer(timeInterval: connectionTimeout, target: self, selector: #selector(connectionTimeoutFired), userInfo: nil, repeats: false)
    }
    
    fileprivate func stopConnectionTimer() {
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
            device.connectionState = .disconnected
            device.RSSI = nil
            
            self.notifyConnectionTimedOut(pending)
        }
    }
    
    //MARK: Notifications
    
    fileprivate func notifyConnectedPeripheral(_ peripheral: CBPeripheral!) {
        let device = bleDeviceForPeripheral(peripheral)
        self.applicationDelegate?.transportConnectedToDevice(device)
        self.connectionDelegate?.connectedToDevice(device)
    }
    
    fileprivate func notifyDisconnectedPeripheral(_ peripheral: CBPeripheral!) {
        let device = bleDeviceForPeripheral(peripheral)
        self.applicationDelegate?.transportDisconnectedFromDevice(device)
    }
    
    fileprivate func notifyConnectionTimedOut(_ peripheral: CBPeripheral) {
        let device = bleDeviceForPeripheral(peripheral)
        self.connectionDelegate?.connectionToDeviceTimedOut(device)
    }
    
    fileprivate func notifyLostConnection(_ peripheral: CBPeripheral) {
        let device = bleDeviceForPeripheral(peripheral)
        self.applicationDelegate?.transportLostConnectionToDevice(device)
    }
    
    fileprivate func notifyLostAllConnections() {
        let peripherals = self.bleDevices.map( { return $0.1.cbPeripheral } )
        for peripheral in peripherals {
            notifyDisconnectedPeripheral(peripheral)
            notifyLostConnection(peripheral!)
        }
    }
    
    //MARK:- Internal
    
    fileprivate func bleDeviceForPeripheral(_ peripheral: CBPeripheral) -> BleDevice {
        if let existing = self.bleDevices[peripheral.identifier] {
            return existing
        }
        
        let device = BleDevice(peripheral: peripheral)
        self.bleDevices[peripheral.identifier] = device
        
        return device
    }
    
    fileprivate var connectedPeripherals: [CBPeripheral] {
        return self.bleDevices.values.filter({
            let result = $0.connectionState == .connected
            return result
        }).map({ $0.cbPeripheral })
    }
    
    fileprivate var peripheralPendingConnection: CBPeripheral? {
        get {
            return self.bleDevices.values.filter({
                let result = $0.connectionState == .connecting
                return result
            }).map({ $0.cbPeripheral }).first
        }
    }
    
    //MARK:- CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        dispatch_main_sync {
            switch(central.state) {
            case .poweredOn:
                self.powerState = .enabled
                
            case .poweredOff: fallthrough
            case .resetting: fallthrough
            case .unauthorized: fallthrough
            case .unknown: fallthrough
            case .unsupported:
                self.powerState = .disabled
                self.stopScanning()
                self.notifyLostAllConnections()
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // RSSI value 127 is Apple-reserved and indicates the RSSI value could not be read.
        if RSSI.intValue != 127 {
            if isThunderboard(peripheral) {
                let device = bleDeviceForPeripheral(peripheral)
                device.RSSI = RSSI.intValue
                
                dispatch_main_async {
                    self.scanningDelegate?.discoveredDevice(device)
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log.info("connected to \(peripheral)")

        let device = bleDeviceForPeripheral(peripheral)
        device.connectionState = .connected
        self.stopConnectionTimer()
        
        dispatch_main_async {
            self.notifyConnectedPeripheral(peripheral)
        }
        
        expectingDisconnect = false
        
        delay(5) {
            peripheral.services?.forEach({ (service) in
                print("---------------------------------------------------")
                print("      Service: \(service.uuid.uuidString) (\(service.uuid))")
                service.characteristics?.forEach({ (characteristic) in
                    print("          Characteristic: \(characteristic.uuid.uuidString) properties \(characteristic.properties)")
                })
            })

        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log.error("failed connection to peripheral \(peripheral) error \(error)")
        
        let device = bleDeviceForPeripheral(peripheral)
        device.connectionState = .disconnected
        self.stopConnectionTimer()
        
        if expectingDisconnect == false {
            dispatch_main_async {
                self.notifyConnectionTimedOut(peripheral)
            }
        }
    }
    

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log.info("disconnected from peripheral \(peripheral) error=\(error)")
        
        let device = bleDeviceForPeripheral(peripheral)
        device.connectionState = .disconnected
        
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
