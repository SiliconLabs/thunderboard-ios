//
//  MotionDemoConnection.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol MotionDemoConnection: DemoConnection {
    weak var connectionDelegate: MotionDemoConnectionDelegate? { get set }
    
    func startCalibration()
    func resetOrientation()
    func resetRevolutions()
    
}

protocol MotionDemoConnectionDelegate: class {
    func demoDeviceDisconnected()

    func startedCalibration()
    func finishedCalbration()
    
    func startedOrientationReset()
    func finishedOrientationReset()
    
    func startedRevolutionsReset()
    func finishedRevolutionsReset()
    
    func orientationUpdated(inclination: ThunderBoardInclination)
    func accelerationUpdated(vector: ThunderBoardVector)
    func rotationUpdated(revolutions: UInt, elapsedTime: NSTimeInterval)
}
