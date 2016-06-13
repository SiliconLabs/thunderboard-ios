//
//  BleIoDemoConnection.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import CoreBluetooth

class BleIoDemoConnection: IoDemoConnection {

    var device: Device
    private var bleDevice: BleDevice {
        get { return device as! BleDevice }
    }
    private var ledMask: UInt8    = 0
    private var buttonMask: UInt8 = 0
    private let digitalBits = 2 // TODO: each digital uses two bits
    private let digitalInputIndexes = [ 0, 1 ]
    private let digitalOutputIndexes = [ 0, 1 ]

    init(device: BleDevice) {
        self.device = device
        self.bleDevice.demoConnectionCharacteristicValueUpdated = { [weak self] (characteristic: CBCharacteristic) in
            self?.characteristicUpdated(characteristic)
        }
        
        self.bleDevice.demoDeviceDisconnectedHook = { [weak self] in
            self?.connectionDelegate?.demoDeviceDisconnected()
        }

        self.bleDevice.readValuesForCharacteristic(CBUUID.Digital)
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
    
    func characteristicUpdated(characteristic: CBCharacteristic) {
        
        if characteristic.UUID == CBUUID.Digital {
            if characteristic.tb_supportsNotification() {
                updateButtonState(characteristic)
                notifyButtonState()
            }
            else {
                updateLedState(characteristic)
                notifyLedState()
            }
        }
    }
    
    weak var connectionDelegate: IoDemoConnectionDelegate? {
        didSet {
            self.bleDevice.readValuesForCharacteristic(CBUUID.Digital)
        }
    }

    func setLed(led: UInt, on: Bool) {
        
        let shift = led * UInt(digitalBits)
        var mask = ledMask
        
        if on {
            mask = mask | UInt8(1 << shift)
        }
        else {
            mask = mask & ~UInt8(1 << shift)
        }

        let data = NSData(bytes: [ mask ], length: 1)
        self.bleDevice.writeValueForCharacteristic(CBUUID.Digital, value: data)

        // *** Note: sending notification optimistically ***
        // Since we're writing the full mask value, LILO applies here,
        // and we *should* end up consistent with the device. Waiting to
        // read back after write causes rubber-banding during fast write sequences. -tt
        ledMask = mask
        notifyLedState()
    }

    func isLedOn(led: UInt) -> Bool {
        return isDigitalHigh(ledMask, index: led)
    }
    
    func isSwitchPressed(switchIndex: UInt) -> Bool {
        return isDigitalHigh(buttonMask, index: switchIndex)
    }

    //MARK: - Internal
    
    private func isDigitalHigh(mask: UInt8, index: UInt) -> Bool {
        let shift = index * UInt(digitalBits)
        let isOn = (mask & UInt8(1 << shift)) != 0
        return isOn
    }
    
    private func updateButtonState(characteristic: CBCharacteristic) {
        guard let newMask = characteristic.tb_uint8Value() else {
            return
        }

        buttonMask = newMask
    }
    
    private func notifyButtonState() {
        for index in digitalInputIndexes {
            self.connectionDelegate?.buttonPressed(index, pressed: isDigitalHigh(buttonMask, index: UInt(index)))
        }
    }

    private func updateLedState(characteristic: CBCharacteristic) {
        guard let newMask = characteristic.tb_uint8Value() else {
            return
        }
        
        ledMask = newMask
    }
    
    private func notifyLedState() {
        for index in digitalOutputIndexes {
            self.connectionDelegate?.ledOn(UInt(index), on: isDigitalHigh(ledMask, index: UInt(index)))
        }
    }
}