//
//  BleEnvironmentDemoConnection.swift
//  ThunderBoard
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
                log.debug("AmbientLight: \(characteristic.tb_hexStringValue()!) -> \(currentData.ambientLight)", function: "")
                notifyUpdatedData()
            }
            
        default:
            break
        }
    }
    
    private func readCurrentValues() {
        self.bleDevice.readValuesForCharacteristic(CBUUID.Temperature)
        self.bleDevice.readValuesForCharacteristic(CBUUID.Humidity)
        self.bleDevice.readValuesForCharacteristic(CBUUID.UVIndex)
        self.bleDevice.readValuesForCharacteristic(CBUUID.AmbientLight)
    }
    
    private func notifyUpdatedData() {
        self.connectionDelegate?.updatedEnvironmentData(currentData)
    }
}