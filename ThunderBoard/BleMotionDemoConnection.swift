//
//  BleMotionDemoConnection.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import CoreBluetooth

class BleMotionDemoConnection: MotionDemoConnection {
    
    var device: Device
    private var bleDevice: BleDevice {
        get { return device as! BleDevice }
    }
    
    weak var connectionDelegate: MotionDemoConnectionDelegate?

    private let startCalibrationId = 0x01
    private let resetOrientationId = 0x02

    init(device: BleDevice) {
        self.device = device
        self.bleDevice.demoConnectionCharacteristicValueUpdated = { [weak self] (characteristic: CBCharacteristic) in
            self?.characteristicUpdated(characteristic)
        }
        self.bleDevice.demoDeviceDisconnectedHook = { [weak self] in
            self?.connectionDelegate?.demoDeviceDisconnected()
        }
    }
    
    func characteristicUpdated(characteristic: CBCharacteristic) {

        switch characteristic.UUID {
        case CBUUID.CSCMeasurement:
            notifyRotation(characteristic)

        case CBUUID.AccelerationMeasurement:
            notifyAcceleration(characteristic)

        case CBUUID.OrientationMeasurement:
            notifyOrientation(characteristic)

        case CBUUID.Command:
            notifyCommand(characteristic)

        case CBUUID.CSCControlPoint:
            notifyCSCControlPoint(characteristic)
            
        default:
            log.debug("unknown UUID: \(characteristic.UUID)")
            break
        }
    }

    // MotionDemoConnection protocol
    
    func startCalibration() {
        let data = NSData(bytes: [ UInt8(0x01) ], length: 1)
        self.bleDevice.writeValueForCharacteristic(CBUUID.Command, value: data)
        
        self.connectionDelegate?.startedCalibration()
    }
    
    func resetOrientation() {
        let data = NSData(bytes: [ UInt8(0x02) ], length: 1)
        self.bleDevice.writeValueForCharacteristic(CBUUID.Command, value: data)
        
        self.connectionDelegate?.startedOrientationReset()
    }
    
    func resetRevolutions() {
        let data = NSData(bytes: [ UInt8(0x01), 0, 0, 0, 0 ], length: 5)
        self.bleDevice.writeValueForCharacteristic(CBUUID.CSCControlPoint, value: data)
        
        self.connectionDelegate?.startedRevolutionsReset()
    }
    
    // Internal
    
    private func notifyRotation(characteristic: CBCharacteristic) {
        if let cscMeasurement:ThunderBoardCSCMeasurement = characteristic.tb_cscMeasurementValue() {
            
            let revolutions = cscMeasurement.revolutionsSinceConnecting
            let elapsedTime = cscMeasurement.secondsSinceConnecting
            self.connectionDelegate?.rotationUpdated(UInt(revolutions), elapsedTime: elapsedTime)
        }
    }
    
    private func notifyOrientation(characteristic: CBCharacteristic) {
        if let inclination = characteristic.tb_inclinationValue() {
            self.connectionDelegate?.orientationUpdated(inclination)
        }
    }
    
    private func notifyAcceleration(characteristic: CBCharacteristic) {
        if let vector = characteristic.tb_vectorValue() {
            self.connectionDelegate?.accelerationUpdated(vector)
        }
    }
    
    private func notifyCommand(characteristic: CBCharacteristic) {
        if let value = characteristic.tb_uint32Value() {
            
            let command = Int(value >> 8) & 0b11
            if command == startCalibrationId {
                self.connectionDelegate?.finishedCalbration()
            }
            
            else if command == resetOrientationId {
                self.connectionDelegate?.finishedOrientationReset()
            }
            
            else {
                log.debug("Unknown notify command: \(command)")
            }
        }
    }
    
    private func notifyCSCControlPoint(characteristic: CBCharacteristic) {
        self.connectionDelegate?.finishedRevolutionsReset()
    }
    
}
