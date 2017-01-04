//
//  DiscoveredDevice.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import CoreBluetooth

class BleDevice : NSObject, Device, DemoConfiguration, CBPeripheralDelegate {
    
    override var debugDescription: String {
        get { return "name=\(name) identifier=\(deviceIdentifier) RSSI=\(RSSI) connectionState=\(connectionState)" }
    }
    
    fileprivate (set) var model: DeviceModel = .unknown
    
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
    
    fileprivate var knownPowerSource: PowerSource?
    fileprivate var knownBatteryLevel: Int?
    fileprivate (set) var power: PowerSource = .unknown {
        didSet {
            notifyConnectedDelegate()
        }
    }

    var firmwareVersion: String? {
        didSet {
            notifyConnectedDelegate()
        }
    }
    
    var connectionState: DeviceConnectionState = .disconnected {
        didSet {
            switch connectionState {
            case .disconnected:
                self.demoDeviceDisconnectedHook?()
            case .connecting: break
            case .connected:
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

    fileprivate (set) var capabilities: Set<DeviceCapability> = []

    var cbPeripheral: CBPeripheral!

    init(peripheral: CBPeripheral) {
        super.init()
        self.cbPeripheral = peripheral
        self.cbPeripheral?.delegate = self

        if let name = peripheral.name {
            self.name = name
        }
    }
    
    func readValuesForCharacteristic(_ uuid: CBUUID) {
        guard let characteristics = self.findCharacteristics(uuid, properties: .read) else {
            return
        }
        
        characteristics.forEach({
            log.debug("reading characteristic \($0)")
            self.cbPeripheral?.readValue(for: $0)
        })
    }

    func writeValueForCharacteristic(_ uuid: CBUUID, value: Data) {
        guard let characteristics = self.findCharacteristics(uuid, properties: .write) else {
            return
        }
        
        characteristics.forEach({
            log.debug("writing value to characteristic \($0)")
            self.cbPeripheral.writeValue(value, for: $0, type: .withResponse)
        })
    }
    
    //MARK:- ConnectedDevice
    
    weak var connectedDelegate: ConnectedDeviceDelegate? {
        didSet {
            notifyConnectedDelegate()
        }
    }
    
    fileprivate func notifyConnectedDelegate() {
        if let name = self.name {
            self.connectedDelegate?.connectedDeviceUpdated(name, RSSI: self.RSSI, power: self.power, identifier: self.deviceIdentifier, firmwareVersion: self.firmwareVersion)
        }
    }
    
    fileprivate func notifyDeviceIdentifierChanged() {
        guard let identifier = self.deviceIdentifier else {
            return
        }
        
        self.configurationDelegate?.deviceIdentifierUpdated(identifier)
    }
    
    //MARK:- DemoConfiguration
    
    typealias CharacteristicHook = ((_ characteristic: CBCharacteristic) -> Void)
    internal var characteristicNotificationUpdateHook: CharacteristicHook?
    internal var characteristicUpdateHook: CharacteristicHook?
    internal var characteristicDidWriteHook: CharacteristicHook?
    weak var configurationDelegate: DemoConfigurationDelegate?
    
    func configureForDemo(_ demo: ThunderboardDemo) {
        switch demo {
        case .io:
            configureIoDemo()
        case .environment:
            configureEnvironmentDemo()
        case .motion:
            configureMotionDemo()
        }
    }
    
    //MARK:- Demo Connection Proxy Hooks
    
    internal var demoConnectionCharacteristicValueUpdated: ((_ characteristic: CBCharacteristic) -> Void)?
    internal var demoDeviceDisconnectedHook: (() -> Void)?
    
    //MARK:- Private
    
    fileprivate func discoverServices() {
        self.cbPeripheral.discoverServices(nil)
    }
    
    func findCharacteristics(_ uuid: CBUUID, properties: CBCharacteristicProperties) -> [CBCharacteristic]? {
        return allCharacteristics.filter({
            return $0.uuid == uuid && ($0.properties.rawValue & properties.rawValue == properties.rawValue)
        })
    }
    
    func findCharacteristic(_ uuid: CBUUID, properties: CBCharacteristicProperties) -> CBCharacteristic? {
        guard let characteristics = findCharacteristics(uuid, properties: properties) else {
            return nil
        }
        
        return characteristics.first
    }
    
    var allCharacteristics: [CBCharacteristic] {
        var result = Array<CBCharacteristic>()
        self.cbPeripheral.services?.forEach({
            $0.characteristics?.forEach({
                result.append($0)
            })
        })
        
        return result
    }
    
    fileprivate func reportConnectedDevice() {
        let settings = ThunderboardSettings()
        guard let name = self.name, let identifier = self.deviceIdentifier else {
            return
        }
        
        let device = NotificationDevice(name: name, identifier: identifier)
        settings.addConnectedDevice(device)
    }
    
    fileprivate func updateBatteryLevel(_ level: Int) {
        knownBatteryLevel = level
        updatePower()
    }
    
    fileprivate func updateKnownPower(_ power: PowerSource) {
        knownPowerSource = power
        updatePower()
    }
    
    fileprivate func updatePower() {
        guard let knownPower = knownPowerSource, let knownbattery = knownBatteryLevel else {
            log.debug("known power information not available -- cannot update power")
            return
        }

        switch knownPower {
        case .unknown:
            break
        case .usb:
            power = .usb
        case .genericBattery:
            power = .genericBattery(knownbattery)
        case .aa:
            power = .aa(knownbattery)
        case .coinCell:
            power = .coinCell(knownbattery)
        }
    }
    
    fileprivate func updateCapabilities(_ characteristics: [CBCharacteristic]) {
        // map characteristics to capabilities
        capabilities = capabilities.union(characteristics.flatMap({ (characteristic: CBCharacteristic) -> DeviceCapability? in
            switch characteristic.uuid {
                
            case CBUUID.Digital:
                if characteristic.tb_supportsWrite() {
                    return .digitalOutput
                }
                
                return .digitalInput
                
            case CBUUID.SenseRGBOutput:
                return .rgbOutput

            case CBUUID.Temperature:
                return .temperature
                
            case CBUUID.Humidity:
                return .humidity
                
            case CBUUID.AmbientLight:
                return .ambientLight
                
            case CBUUID.UVIndex:
                return .uvIndex

            case CBUUID.Pressure:
                return .airPressure
                
            case CBUUID.Command:
                return .calibration

            case CBUUID.AccelerationMeasurement:
                return .acceleration
                
            case CBUUID.OrientationMeasurement:
                return .orientation
                
            case CBUUID.CSCMeasurement:
                return .revolutions
                
            case CBUUID.SoundLevelCustom:
                return .soundLevel

            case CBUUID.SenseAirQualityCarbonDioxide:
                return .airQualityCO2
                
            case CBUUID.SenseAirQualityVolatileOrganicCompounds:
                return .airQualityVOC
                
            case CBUUID.PowerSourceCharacteristicCustom:
                return .powerSource
                
            default:
                return nil
            }
            
        }))
        
        log.debug("updated capabilities: \(capabilities)")
    }
    
    //MARK:- Characteristic Helpers
    
    func batteryCharacteristic() -> CBCharacteristic? {
        return findCharacteristic(CBUUID.BatteryLevel, properties: .notify)
    }
    
    func digitalInputCharacteristic() -> CBCharacteristic? {
        return findCharacteristic(CBUUID.Digital, properties: .notify)
    }

    //MARK:- Equality (Objective-C)
    
    override func isEqual(_ object: Any?) -> Bool {
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

    @objc func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        guard let updatedName = peripheral.name else {
            return
        }
        
        dispatch_main_sync {
            self.name = updatedName
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        dispatch_main_sync {
            self.RSSI = RSSI.intValue
        }
    }
    
    //MARK:- CBPeripheralDelegate (Services)
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // discover all characteristics
        peripheral.services?.forEach({
            peripheral.discoverCharacteristics(nil, for: $0)
        })
        
        // if the custom power source service is available, we'll wait for
        // its characteristic to be read. otherwise, we can assume battery power
        if peripheral.services?.filter({ $0.uuid == CBUUID.PowerSourceServiceCustom }).count == 0 {
            updateKnownPower(.genericBattery(0))
        }
        else {
            updateKnownPower(.unknown)
        }
    }
    
    //MARK:- CBPeripheralDelegate (Characteristics)
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        log.debug("service: \(service.uuid) characteristics: \(service.characteristics)")
        
        // update capabilities based on characteristics
        updateCapabilities(characteristics)

        characteristics.forEach({
            
            switch $0.uuid {
            case CBUUID.BatteryLevel:
                peripheral.setNotifyValue(true, for: $0)
                
            case CBUUID.PowerSourceCharacteristicCustom:
                peripheral.readValue(for: $0)
                
            default:
                // read all supported values
                if $0.tb_supportsRead() {
                    peripheral.readValue(for: $0)
                }
            }
        })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        dispatch_main_sync {
            if error == nil {
                self.characteristicDidWriteHook?(characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        dispatch_main_sync {
            
            switch characteristic.uuid {
            case CBUUID.BatteryLevel:
                if let value = characteristic.tb_int8Value() {
                    self.updateBatteryLevel(Int(value))
                }
                
            case CBUUID.ModelNumber:
                if let model = characteristic.tb_stringValue() {
                    log.info("model: \(model)")
                    
                    switch model.uppercased() {
                    case "RD-0057":
                        self.model = .react
                    case "BRD4160A":
                        self.model = .sense
                    default:
                        self.model = .unknown
                    }
                }
                
            case CBUUID.FirmwareRevision:
                if let value = characteristic.tb_stringValue() {
                    log.info("Firmware Version: \(value)")
                    self.firmwareVersion = value
                }
                
            case CBUUID.HardwareRevision:
                if let value = characteristic.tb_stringValue() {
                    log.info("Hardware Revision: \(value)")
                }
                
            case CBUUID.SystemIdentifier:
                if let value = characteristic.tb_hexStringValue() {
                    log.info("System ID: \(value)")
                }
                
                if let systemId = characteristic.tb_uint64value() {
                    let uniqueIdentifier = systemId.bigEndian & 0xFFFFFF
                    self.deviceIdentifier = DeviceId(uniqueIdentifier)
                    
                    log.info("Unique ID \(uniqueIdentifier)")
                    
                    self.reportConnectedDevice()
                }
                
            case CBUUID.PowerSourceCharacteristicCustom:
                if let value = characteristic.tb_uint8Value() {
                    //    <!-- 0x00 : POWER_SOURCE_TYPE_UNKNOWN   -->
                    //    <!-- 0x01 : POWER_SOURCE_TYPE_USB       -->
                    //    <!-- 0x02 : POWER_SOURCE_TYPE_AA        -->
                    //    <!-- 0x03 : POWER_SOURCE_TYPE_AAA       -->
                    //    <!-- 0x04 : POWER_SOURCE_TYPE_COIN_CELL -->
                    log.debug("power source: \(value)")
                    switch value {
                    case 1:
                        self.knownPowerSource = .usb
                    case 2, 3:
                        self.knownPowerSource = .aa(0)
                    case 4:
                        self.knownPowerSource = .coinCell(0)
                    default:
                        break
                    }
                    
                    self.updatePower()
                }
                
            default:
                break
            }

            if error == nil {
                self.characteristicUpdateHook?(characteristic)
                self.demoConnectionCharacteristicValueUpdated?(characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        dispatch_main_sync {
            if error == nil {
                log.debug("Characteristic \(characteristic.uuid) notifying \(characteristic.isNotifying)")
                self.characteristicNotificationUpdateHook?(characteristic)
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
