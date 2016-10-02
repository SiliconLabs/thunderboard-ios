//
//  MotionDemoConnection.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol MotionDemoConnection: DemoConnection {
    weak var connectionDelegate: MotionDemoConnectionDelegate? { get set }
    
    func startCalibration()
    func resetOrientation()
    func resetRevolutions()
    func readLedColor()
}

protocol MotionDemoConnectionDelegate: class {
    func demoDeviceDisconnected()

    func startedCalibration()
    func finishedCalbration()
    
    func startedOrientationReset()
    func finishedOrientationReset()
    
    func startedRevolutionsReset()
    func finishedRevolutionsReset()
    
    func orientationUpdated(inclination: ThunderboardInclination)
    func accelerationUpdated(vector: ThunderboardVector)
    func rotationUpdated(revolutions: UInt, elapsedTime: NSTimeInterval)
    func ledColorUpdated(on: Bool, color: LedRgb)
}

extension MotionDemoConnection {
    var capabilities: Set<DeviceCapability> {
        let environmentCapabilities: Set<DeviceCapability> = [
            .Acceleration,
            .Orientation,
            .Calibration,
            .Revolutions,
            .RGBOutput,
        ]
        
        return device.capabilities.intersect(environmentCapabilities)
    }
}