//
//  SimulatedMotionDemoConnection.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class SimulatedMotionDemoConnection: MotionDemoConnection {

    var device: Device
    private var simulatedDevice: SimulatedDevice {
        get { return device as! SimulatedDevice }
    }
    weak var connectionDelegate: MotionDemoConnectionDelegate?
    
    private let simulationInterval: NSTimeInterval = 0.25
    private let simulationRotationsPerSample: UInt = 5
    private var simulationTimer: WeakTimer?
    
    init(device: SimulatedDevice) {
        self.device = device

        self.simulationTimer = WeakTimer.scheduledTimer(simulationInterval, repeats: true, action: { [weak self] () -> Void in
            self?.simulateDataUpdate()
        })
    }
    
    func startCalibration() {
        self.connectionDelegate?.startedCalibration()
        self.simulatedDevice.startCalibration { [weak self] () -> Void in
            self?.connectionDelegate?.finishedCalbration()
        }
    }
    
    func resetOrientation() {
        self.connectionDelegate?.startedOrientationReset()
        delay(1) { [weak self] () -> Void in
            self?.connectionDelegate?.finishedOrientationReset()
        }
    }
    
    func resetRevolutions() {
        self.connectionDelegate?.startedRevolutionsReset()
        self.cumulativeRotations = 0
        delay(1) { [weak self] () -> Void in
            self?.connectionDelegate?.finishedRevolutionsReset()
        }
    }
    
    //MARK: - Private

    private var currentSample               = 0
    
    private var elapsedTime: NSTimeInterval = 0
    private var cumulativeRotations: UInt   = 0
    func simulateDataUpdate() {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            
            self.simulateAccelerationData()
            self.simulateOrientation()
            self.simulateRotation()
            
            self.currentSample += 2
            if self.currentSample > 180 {
                self.currentSample = -180
            }
            
            self.elapsedTime += self.simulationInterval
            self.cumulativeRotations += self.simulationRotationsPerSample
        })
    }
    
    func simulateAccelerationData() {
        connectionDelegate?.accelerationUpdated(randomAccelerationVector())
    }
    
    func simulateOrientation() {
        connectionDelegate?.orientationUpdated(ThunderBoardInclination(x: 0, y: 0, z: 90))
//        connectionDelegate?.orientationUpdated(ThunderBoardInclination(x: 0, y: 10, z: Float(currentSample)))
    }
    
    func simulateRotation() {
        connectionDelegate?.rotationUpdated(cumulativeRotations, elapsedTime: elapsedTime)
    }
    
    private func randomOrientationVector() -> ThunderBoardInclination {
        let scale: Degree = 360
        
        let vector = ThunderBoardInclination(
            x: randomFloat() * scale - (scale / 2),
            y: randomFloat() * scale - (scale / 2),
            z: randomFloat() * scale - (scale / 2)
        )
        
        return vector
    }
    
    private func randomAccelerationVector() -> ThunderBoardVector {
        let scale: α = 2
        let vector = ThunderBoardVector(
            x: randomFloat() * scale - (scale / 2),
            y: randomFloat() * scale - (scale / 2),
            z: randomFloat() * scale - (scale / 2)
        )
        return vector
    }
    
    private func randomFloat() -> Float {
        return ceilf(Float(random())/Float(RAND_MAX) * 100) / 100
    }
}
