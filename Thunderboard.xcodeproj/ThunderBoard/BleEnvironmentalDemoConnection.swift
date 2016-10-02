//
//  BleEnvironmentDemoConnection.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import CoreBluetooth

class BleEnvironmentDemoConnection : EnvironmentDemoConnection {
    
    var device: Device
    private var bleDevice: BleDevice {
        get { return device as! BleDevice }
    }
    
    private var currentData: EnvironmentData = EnvironmentData()
    private var pollingTimer: WeakTimer?
    private var vocEnabled = false
    private var co2Enabled = false
    weak var connectionDelegate: EnvironmentDemoConnectionDelegate?

    init(device: BleDevice) {
        self.device = device
        self.bleDevice.demoConnectionCharacteristicValueUpdated = { [weak self] (characteristic: CBCharacteristic) in
            self?.characteristicUpdated(characteristic)
        }
        self.bleDevice.demoDeviceDisconnectedHook = { [weak self] in
            self?.connectionDelegate?.demoDeviceDisconnected()
        }
        
        pollingTimer = WeakTimer.scheduledTimer(3, repeats: true, action: { [weak self] () -> Void in
            self?.readCurrentValues()
        })

        self.readCurrentValues()
    }

    var deviceId: DeviceId {
        get {
            guard let id = device.deviceIdentifier else {
                return 0
            }
            
            return id
        }
        set { }
    }

    private func characteristicUpdated(characteristic: CBCharacteristic) {
        switch characteristic.UUID {
        case CBUUID.Temperature:
            if let temperature = characteristic.tb_int16Value() {
                currentData.temperature = Double(temperature)/100
                notifyUpdatedData()
            }

        case CBUUID.Humidity:
            if let humidity = characteristic.tb_int16Value() {
                currentData.humidity = Double(humidity)/100
                notifyUpdatedData()
            }
        case CBUUID.UVIndex:
            if let uv = characteristic.tb_uint8Value() {
                currentData.uvIndex = Double(uv)
                notifyUpdatedData()
            }

        case CBUUID.AmbientLight:
            if let ambient = characteristic.tb_uint32Value() {
                currentData.ambientLight = Double(ambient / 100) // delivered with hundredths precision
                notifyUpdatedData()
            }
            
        case CBUUID.SenseAirQualityCarbonDioxide:
            if let co2 = characteristic.tb_uint16Value() {
                co2Enabled = true
                currentData.co2 = CarbonDioxideReading(enabled: co2Enabled, value: AirQualityCO2(co2))
                notifyUpdatedData()
            }
            
        case CBUUID.SenseAirQualityVolatileOrganicCompounds:
            if let voc = characteristic.tb_uint16Value() {
                vocEnabled = true
                currentData.voc = VolatileOrganicCompoundsReading(enabled: vocEnabled, value: AirQualityVOC(voc))
                notifyUpdatedData()
            }
            
        case CBUUID.SoundLevelCustom:
            if let db = characteristic.tb_int16Value() {
                currentData.sound = SoundLevel(db / 100)
                notifyUpdatedData()
            }
            
        case CBUUID.Pressure:
            if let pressure = characteristic.tb_uint32Value() {
                currentData.pressure = AtmosphericPressure(pressure / 1000)
                notifyUpdatedData()
            }
            
        default:
            break
        }
    }
    
    private func readCurrentValues() {

        capabilities.forEach({
            switch $0 {
            case .Temperature:
                bleDevice.readValuesForCharacteristic(CBUUID.Temperature)
            case .Humidity:
                bleDevice.readValuesForCharacteristic(CBUUID.Humidity)
            case .UVIndex:
                bleDevice.readValuesForCharacteristic(CBUUID.UVIndex)
            case .AmbientLight:
                bleDevice.readValuesForCharacteristic(CBUUID.AmbientLight)
            case .AirQualityCO2:
                bleDevice.readValuesForCharacteristic(CBUUID.SenseAirQualityCarbonDioxide)
            case .AirQualityVOC:
                bleDevice.readValuesForCharacteristic(CBUUID.SenseAirQualityVolatileOrganicCompounds)
            case .SoundLevel:
                bleDevice.readValuesForCharacteristic(CBUUID.SoundLevelCustom)
            case .AirPressure:
                bleDevice.readValuesForCharacteristic(CBUUID.Pressure)
            default:
                break
            }
        })
    }
    
    private func notifyUpdatedData() {
        self.connectionDelegate?.updatedEnvironmentData(currentData)
    }
}