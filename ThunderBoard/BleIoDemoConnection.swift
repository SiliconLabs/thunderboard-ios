//
//  BleIoDemoConnection.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import CoreBluetooth

class BleIoDemoConnection: IoDemoConnection {

    var device: Device
    
    var numberOfLeds: Int {
        return 2 + ((hasAnalogRgb) ? 1 : 0)
    }
    
    var numberOfSwitches: Int {
        return 2    // TODO: detect this value based on digital characteristics
    }

    private var bleDevice: BleDevice {
        get { return device as! BleDevice }
    }
    
    private var ledMask: UInt8    = 0
    private var buttonMask: UInt8 = 0
    private let digitalBits = 2 // TODO: each digital uses two bits
    private let digitalInputIndexes = [ 0, 1 ]
    private let digitalOutputIndexes = [ 0, 1 ]
    private var analogState: LedState?  // only support one analog LED currently
    private let hasAnalogRgb: Bool
    private let ledWriteThrottle = Throttle(interval: 0.25) // up to four writes per second

    init(device: BleDevice) {
        self.device = device
        
        hasAnalogRgb = device.capabilities.contains(.RGBOutput)
        
        self.bleDevice.demoConnectionCharacteristicValueUpdated = { [weak self] (characteristic: CBCharacteristic) in
            self?.characteristicUpdated(characteristic)
        }
        
        self.bleDevice.demoDeviceDisconnectedHook = { [weak self] in
            self?.connectionDelegate?.demoDeviceDisconnected()
        }

        self.bleDevice.readValuesForCharacteristic(CBUUID.Digital)
    }
    
    var deviceId: DeviceId {
        guard let id = device.deviceIdentifier else {
            return 0
        }
        
        return id
    }
    
    func characteristicUpdated(characteristic: CBCharacteristic) {
        log.debug("updated \(characteristic)")
        switch characteristic.UUID {
        case CBUUID.Digital:
            if characteristic.tb_supportsNotificationOrIndication() {
                updateButtonState(characteristic)
                notifyButtonState()
            }
            else {
                updateLedState(characteristic)
                notifyLedState()
            }
            
        case CBUUID.SenseRGBOutput:
            updateLedState(characteristic)
            notifyLedState()
            
        default:
            break
        }
    }
    
    weak var connectionDelegate: IoDemoConnectionDelegate? {
        didSet {
            self.bleDevice.readValuesForCharacteristic(CBUUID.Digital)
            self.bleDevice.readValuesForCharacteristic(CBUUID.SenseRGBOutput)
        }
    }

    func setLed(led: Int, state: LedState) {
        switch state {
        case .Digital(let on, _):
            setDigitalOutput(led, on: on)
        case .RGB(let on, let color):
            setAnalogOutput(on, color: color)
        }
    }

    func ledState(led: Int) -> LedState {
        if digitalOutputIndexes.contains(led) {
            return digitalState(ledMask, index: led)
        }
        else {
            return analogState(2)
        }
    }
    
    func isSwitchPressed(switchIndex: Int) -> Bool {
        return isDigitalHigh(buttonMask, index: switchIndex)
    }

    //MARK: - Internal
    
    private func setDigitalOutput(index: Int, on: Bool) {
        let shift = UInt(index) * UInt(digitalBits)
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
    
    private func setAnalogOutput(on: Bool, color: LedRgb) {
        let data = colorDataForLedRgb(on, color: color)
        
        ledWriteThrottle.run() {
            self.bleDevice.writeValueForCharacteristic(CBUUID.SenseRGBOutput, value: data)
        }

        // Send analog notification optimistically
        analogState = LedState.RGB(on, color)
        notifyLedState()
    }
    
    private func digitalState(mask: UInt8, index: Int) -> LedState {
        let ledColor = device.ledColor(index)
        return LedState.Digital(isDigitalHigh(ledMask, index: index), ledColor)
    }
    
    private func analogState(index: Int) -> LedState {
        guard let analogState = analogState else {
            log.error("invalid analog state")
            return LedState.RGB(false, LedRgb(red: 0, green: 0, blue: 0))
        }
        
        return analogState
    }
    
    private func isDigitalHigh(mask: UInt8, index: Int) -> Bool {
        let shift = index * Int(digitalBits)
        return (mask & UInt8(1 << shift)) != 0
    }
    
    private func updateButtonState(characteristic: CBCharacteristic) {
        guard let newMask = characteristic.tb_uint8Value() else {
            return
        }

        buttonMask = newMask
    }
    
    private func notifyButtonState() {
        for index in digitalInputIndexes {
            self.connectionDelegate?.buttonPressed(index, pressed: isDigitalHigh(buttonMask, index: index))
        }
    }

    private func updateLedState(characteristic: CBCharacteristic) {
        switch characteristic.UUID {
        case CBUUID.Digital:
            ledMask = characteristic.tb_uint8Value() ?? ledMask
            break
        case CBUUID.SenseRGBOutput:
            analogState = characteristic.tb_analogLedState()
            break
        default:
            break
        }
    }
    
    private func notifyLedState() {
        for index in digitalOutputIndexes {
            let state = digitalState(ledMask, index: index)
            self.connectionDelegate?.updatedLed(index, state: state)
        }
        
        if let analogState = analogState {
            self.connectionDelegate?.updatedLed(2, state: analogState)
        }
    }
    
    private func colorDataForLedRgb(on: Bool, color: LedRgb) -> NSData {
        // 0000
        // 0001 0x01 back, lower (near USB)
        // 0010 0x02 back, upper
        // 0100 0x04 front, upper
        // 1000 0x08 front, lower (near USB)
        let enabledLeds = on ? UInt8(0x0F) : UInt8(0x00)
        return NSData(bytes: [enabledLeds, UInt8(color.red * 255),UInt8(color.green * 255),UInt8(color.blue * 255)] as [UInt8], length: 4)
    }
}