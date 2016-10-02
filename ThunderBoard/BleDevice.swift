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
    
    private (set) var model: DeviceModel = .Unknown
    
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
    
    private var knownPowerSource: PowerSource?
    private var knownBatteryLevel: Int?
    private (set) var power: PowerSource = .Unknown {
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

    private (set) var capabilities: Set<DeviceCapability> = []

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
        
        characteristics.forEach({
            log.debug("reading characteristic \($0)")
            self.cbPeripheral?.readValueForCharacteristic($0)
        })
    }

    func writeValueForCharacteristic(uuid: CBUUID, value: NSData) {
        guard let characteristics = self.findCharacteristics(uuid, properties: .Write) else {
            return
        }
        
        characteristics.forEach({
            log.debug("writing value to characteristic \($0)")
            self.cbPeripheral.writeValue(value, forCharacteristic: $0, type: .WithResponse)
        })
    }
    
    //MARK:- ConnectedDevice
    
    weak var connectedDelegate: ConnectedDeviceDelegate? {
        didSet {
            notifyConnectedDelegate()
        }
    }
    
    private func notifyConnectedDelegate() {
        if let name = self.name {
            self.connectedDelegate?.connectedDeviceUpdated(name, RSSI: self.RSSI, power: self.power, identifier: self.deviceIdentifier, firmwareVersion: self.firmwareVersion)
        }
    }
    
    private func notifyDeviceIdentifierChanged() {
        guard let identifier = self.deviceIdentifier else {
            return
        }
        
        self.configurationDelegate?.deviceIdentifierUpdated(identifier)
    }
    
    //MARK:- DemoConfiguration
    
    typealias CharacteristicHook = ((characteristic: CBCharacteristic) -> Void)
    internal var characteristicNotificationUpdateHook: CharacteristicHook?
    internal var characteristicUpdateHook: CharacteristicHook?
    internal var characteristicDidWriteHook: CharacteristicHook?
    weak var configurationDelegate: DemoConfigurationDelegate?
    
    func configureForDemo(demo: ThunderboardDemo) {
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
        return allCharacteristics.filter({
            return $0.UUID == uuid && ($0.properties.rawValue & properties.rawValue == properties.rawValue)
        })
    }
    
    func findCharacteristic(uuid: CBUUID, properties: CBCharacteristicProperties) -> CBCharacteristic? {
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
    
    private func reportConnectedDevice() {
        let settings = ThunderboardSettings()
        guard let name = self.name, identifier = self.deviceIdentifier else {
            return
        }
        
        let device = NotificationDevice(name: name, identifier: identifier)
        settings.addConnectedDevice(device)
    }
    
    private func updateBatteryLevel(level: Int) {
        knownBatteryLevel = level
        updatePower()
    }
    
    private func updateKnownPower(power: PowerSource) {
        knownPowerSource = power
        updatePower()
    }
    
    private func updatePower() {
        guard let knownPower = knownPowerSource, knownbattery = knownBatteryLevel else {
            log.debug("known power information not available -- cannot update power")
            return
        }

        switch knownPower {
        case .Unknown:
            break
        case .USB:
            power = .USB
        case .GenericBattery:
            power = .GenericBattery(knownbattery)
        case .AA:
            power = .AA(knownbattery)
        case .CoinCell:
            power = .CoinCell(knownbattery)
        }
    }
    
    private func updateCapabilities(characteristics: [CBCharacteristic]) {
        // map characteristics to capabilities
        capabilities = capabilities.union(characteristics.flatMap({ (characteristic: CBCharacteristic) -> DeviceCapability? in
            switch characteristic.UUID {
                
            case CBUUID.Digital:
                if characteristic.tb_supportsWrite() {
                    return .DigitalOutput
                }
                
                return .DigitalInput
                
            case CBUUID.SenseRGBOutput:
                return .RGBOutput

            case CBUUID.Temperature:
                return .Temperature
                
            case CBUUID.Humidity:
                return .Humidity
                
            case CBUUID.AmbientLight:
                return .AmbientLight
                
            case CBUUID.UVIndex:
                return .UVIndex

            case CBUUID.Pressure:
                return .AirPressure
                
            case CBUUID.Command:
                return .Calibration

            case CBUUID.AccelerationMeasurement:
                return .Acceleration
                
            case CBUUID.OrientationMeasurement:
                return .Orientation
                
            case CBUUID.CSCMeasurement:
                return .Revolutions
                
            case CBUUID.SoundLevelCustom:
                return .SoundLevel

            case CBUUID.SenseAirQualityCarbonDioxide:
                return .AirQualityCO2
                
            case CBUUID.SenseAirQualityVolatileOrganicCompounds:
                return .AirQualityVOC
                
            case CBUUID.PowerSourceCharacteristicCustom:
                return .PowerSource
                
            default:
                return nil
            }
            
        }))
        
        log.debug("updated capabilities: \(capabilities)")
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
        // discover all characteristics
        peripheral.services?.forEach({
            peripheral.discoverCharacteristics(nil, forService: $0)
        })
        
        // if the custom power source service is available, we'll wait for
        // its characteristic to be read. otherwise, we can assume battery power
        if peripheral.services?.filter({ $0.UUID == CBUUID.PowerSourceServiceCustom }).count == 0 {
            updateKnownPower(.GenericBattery(0))
        }
        else {
            updateKnownPower(.Unknown)
        }
    }
    
    //MARK:- CBPeripheralDelegate (Characteristics)
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        log.debug("service: \(service.UUID) characteristics: \(service.characteristics)")
        
        // update capabilities based on characteristics
        updateCapabilities(characteristics)

        characteristics.forEach({
            
            switch $0.UUID {
            case CBUUID.BatteryLevel:
                peripheral.setNotifyValue(true, forCharacteristic: $0)
                
            case CBUUID.PowerSourceCharacteristicCustom:
                peripheral.readValueForCharacteristic($0)
                
            default:
                // read all supported values
                if $0.tb_supportsRead() {
                    peripheral.readValueForCharacteristic($0)
                }
            }
        })
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
            
            switch characteristic.UUID {
            case CBUUID.BatteryLevel:
                if let value = characteristic.tb_int8Value() {
                    self.updateBatteryLevel(Int(value))
                }
                
            case CBUUID.ModelNumber:
                if let model = characteristic.tb_stringValue() {
                    log.info("model: \(model)")
                    
                    switch model.uppercaseString {
                    case "RD-0057":
                        self.model = .React
                    case "BRD4160A":
                        self.model = .Sense
                    default:
                        self.model = .Unknown
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
                        self.knownPowerSource = .USB
                    case 2, 3:
                        self.knownPowerSource = .AA(0)
                    case 4:
                        self.knownPowerSource = .CoinCell(0)
                    default:
                        break
                    }
                    
                    self.updatePower()
                }
                
            default:
                break
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
