//
//  DiscoveredDevice.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import CoreBluetooth

class BleDevice : NSObject, Device, DemoConfiguration, CBPeripheralDelegate {
    
    override var debugDescription: String {
        get { return "name=\(name) identifier=\(deviceIdentifier) RSSI=\(RSSI) connectionState=\(connectionState)" }
    }
    
    var name: String? {
        didSet {
            notifyConnectedDelegate()
        }
    }
    var RSSI: Int? {
        didSet {
            notifyConnectedDelegate()
        }
    }
    
    var batteryLevel: Int? {
        didSet {
            notifyConnectedDelegate()
        }
    }
    
    var firmwareVersion: String? {
        didSet {
            notifyConnectedDelegate()
        }
    }
    
    var connectionState: DeviceConnectionState = .Disconnected {
        didSet {
            switch connectionState {
            case .Disconnected:
                self.demoDeviceDisconnectedHook?()
            case .Connecting: break
            case .Connected:
                self.cbPeripheral?.readRSSI()
                discoverServices()
            }
        }
    }
    
    var deviceIdentifier: DeviceId? {
        didSet {
            notifyConnectedDelegate()
            notifyDeviceIdentifierChanged()
        }
    }

    var cbPeripheral: CBPeripheral!

    init(peripheral: CBPeripheral) {
        super.init()
        self.cbPeripheral = peripheral
        self.cbPeripheral?.delegate = self

        if let name = peripheral.name {
            self.name = name
        }
    }
    
    func readValuesForCharacteristic(uuid: CBUUID) {
        guard let characteristics = self.findCharacteristics(uuid, properties: .Read) else {
            return
        }
        
        for (_, characteristic) in characteristics.enumerate() {
            self.cbPeripheral?.readValueForCharacteristic(characteristic)
        }
    }

    func writeValueForCharacteristic(uuid: CBUUID, value: NSData) {
        guard let characteristics = self.findCharacteristics(uuid, properties: .Write) else {
            return
        }
        
        for (_, characteristic) in characteristics.enumerate() {
            self.cbPeripheral.writeValue(value, forCharacteristic: characteristic, type: .WithResponse)
        }
    }
    
    //MARK:- ConnectedDevice
    
    weak var connectedDelegate: ConnectedDeviceDelegate? {
        didSet {
            notifyConnectedDelegate()
        }
    }
    
    private func notifyConnectedDelegate() {
        if let name = self.name {
            self.connectedDelegate?.connectedDeviceUpdated(name, RSSI: self.RSSI, battery: self.batteryLevel, identifier: self.deviceIdentifier, firmwareVersion: self.firmwareVersion)
        }
    }
    
    private func notifyDeviceIdentifierChanged() {
        guard let identifier = self.deviceIdentifier else {
            return
        }
        
        self.configurationDelegate?.deviceIdentifierUpdated(identifier)
    }
    
    func demoConfiguration() -> DemoConfiguration {
        return self
    }
    
    //MARK:- DemoConfiguration
    
    typealias CharacteristicHook = ((characteristic: CBCharacteristic) -> Void)
    internal var characteristicNotificationUpdateHook: CharacteristicHook?
    internal var characteristicUpdateHook: CharacteristicHook?
    internal var characteristicDidWriteHook: CharacteristicHook?
    weak var configurationDelegate: DemoConfigurationDelegate?
    
    func configureForDemo(demo: ThunderBoardDemo) {
        switch demo {
        case .IO:
            configureIoDemo()
        case .Environment:
            configureEnvironmentDemo()
        case .Motion:
            configureMotionDemo()
        }
    }
    
    //MARK:- Demo Connection Proxy Hooks
    
    internal var demoConnectionCharacteristicValueUpdated: ((characteristic: CBCharacteristic) -> Void)?
    internal var demoDeviceDisconnectedHook: (() -> Void)?
    
    //MARK:- Private
    
    private func discoverServices() {
        self.cbPeripheral.discoverServices(nil)
    }
    
    func findCharacteristics(uuid: CBUUID, properties: CBCharacteristicProperties) -> [CBCharacteristic]? {
        guard let characteristics = allCharacteristics() else {
            return nil
        }
        
        return characteristics.filter({
            return $0.UUID == uuid && ($0.properties.rawValue & properties.rawValue == properties.rawValue)
        })
    }
    
    func findCharacteristic(uuid: CBUUID, properties: CBCharacteristicProperties) -> CBCharacteristic? {
        guard let characteristics = findCharacteristics(uuid, properties: properties) else {
            return nil
        }
        
        return characteristics.first
    }
    
    func allCharacteristics() -> [CBCharacteristic]? {
        guard let services = self.cbPeripheral.services else {
            return nil
        }
        
        var result = Array<CBCharacteristic>()
        for service in services {
            guard let characteristics = service.characteristics else {
                continue
            }
            
            for characteristic in characteristics {
                result.append(characteristic)
            }
        }
        
        return result
    }
    
    func enumerateCharacteristics(block: (characteristic: CBCharacteristic) -> Void) {
        
        guard let characteristics = allCharacteristics() else {
            return
        }
        
        let _ = characteristics.filter({
            block(characteristic: $0)
            return false
        })
    }
    
    private func reportConnectedDevice() {
        let settings = ThunderBoardSettings()
        guard let name = self.name, identifier = self.deviceIdentifier else {
            return
        }
        
        let device = NotificationDevice(name: name, identifier: identifier)
        settings.addConnectedDevice(device)
    }
    
    //MARK:- Characteristic Helpers
    
    func batteryCharacteristic() -> CBCharacteristic? {
        return findCharacteristic(CBUUID.BatteryLevel, properties: .Notify)
    }
    
    func digitalInputCharacteristic() -> CBCharacteristic? {
        return findCharacteristic(CBUUID.Digital, properties: .Notify)
    }

    //MARK:- Equality (Objective-C)
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? BleDevice {
            return object == self
        } else {
            return false
        }
    }
    
    override var hashValue: Int {
        return cbPeripheral.hashValue
    }
    
    //MARK:- CBPeripheralDelegate

    @objc func peripheralDidUpdateName(peripheral: CBPeripheral) {
        guard let updatedName = peripheral.name else {
            return
        }
        
        dispatch_main_sync {
            self.name = updatedName
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        dispatch_main_sync {
            self.RSSI = RSSI.integerValue
        }
    }
    
    //MARK:- CBPeripheralDelegate (Services)
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        // discover battery characteristics
        if let services = peripheral.services {
            for service: CBService in services {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    //MARK:- CBPeripheralDelegate (Characteristics)
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        guard let characteristics = service.characteristics else {
            return
        }

        for characteristic in characteristics {
            // read all supported values
            if characteristic.tb_supportsRead() {
                peripheral.readValueForCharacteristic(characteristic)
            }
            
            // setup battery monitoring
            if characteristic.UUID == CBUUID.BatteryLevel {
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        dispatch_main_sync {
            if error == nil {
                self.characteristicDidWriteHook?(characteristic: characteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        dispatch_main_sync {
            if characteristic.UUID == CBUUID.BatteryLevel {
                if let value = characteristic.tb_int8Value() {
                    self.batteryLevel = Int(value)
                }
            }
            
            if characteristic.UUID == CBUUID.ModelNumber {
                if let model = characteristic.tb_stringValue() {
                    log.info("model: \(model)")
                }
            }
            
            if characteristic.UUID == CBUUID.FirmwareRevision {
                if let value = characteristic.tb_stringValue() {
                    log.info("Firmware Version: \(value)")
                    self.firmwareVersion = value
                }
            }
            
            if characteristic.UUID == CBUUID.HardwareRevision {
                if let value = characteristic.tb_stringValue() {
                    log.info("Hardware Revision: \(value)")
                }
            }
            
            if characteristic.UUID == CBUUID.SystemIdentifier {
                if let value = characteristic.tb_hexStringValue() {
                    log.info("System ID: \(value)")
                }
                
                if let systemId = characteristic.tb_uint64value() {
                    let uniqueIdentifier = systemId.bigEndian & 0xFFFFFF
                    self.deviceIdentifier = DeviceId(uniqueIdentifier)

                    log.info("Unique ID \(uniqueIdentifier)")
                    
                    self.reportConnectedDevice()
                }
            }
            
            if error == nil {
                self.characteristicUpdateHook?(characteristic: characteristic)
                self.demoConnectionCharacteristicValueUpdated?(characteristic: characteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        dispatch_main_sync {
            if error == nil {
                log.debug("Characteristic \(characteristic.UUID) notifying \(characteristic.isNotifying)")
                self.characteristicNotificationUpdateHook?(characteristic: characteristic)
            }
        }
    }
}

//MARK:- Equality

func == (lhs: BleDevice, rhs: BleDevice) -> Bool {
    return lhs.cbPeripheral?.identifier == rhs.cbPeripheral?.identifier
}

func != (lhs: BleDevice, rhs: BleDevice) -> Bool {
    return !(lhs == rhs)
}
