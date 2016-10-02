//
//  SimulatedMotionDemoConnection.swift
//  Thunderboard
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
    
    func readLedColor() {
        // NO-OP - simulated device randomly updates
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
            self.simulateColor()
            
            self.currentSample += 5
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
//        connectionDelegate?.orientationUpdated(ThunderboardInclination(x: 0, y: -65, z: 0))  // Thunderboard-React Model screenshot
//        connectionDelegate?.orientationUpdated(ThunderboardInclination(x: 0, y: 0, z: 90)) // Pinewood Derby model screenshot
        connectionDelegate?.orientationUpdated(ThunderboardInclination(x: 0, y: Float(currentSample), z: 0))
    }
    
    func simulateRotation() {
        connectionDelegate?.rotationUpdated(cumulativeRotations, elapsedTime: elapsedTime)
    }
    
    func simulateColor() {
        connectionDelegate?.ledColorUpdated(false, color: LedRgb.random())
    }
    
    private func randomOrientationVector() -> ThunderboardInclination {
        let scale: Degree = 360
        
        let vector = ThunderboardInclination(
            x: randomFloat() * scale - (scale / 2),
            y: randomFloat() * scale - (scale / 2),
            z: randomFloat() * scale - (scale / 2)
        )
        
        return vector
    }
    
    private func randomAccelerationVector() -> ThunderboardVector {
        let scale: α = 2
        let vector = ThunderboardVector(
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

extension LedRgb {
    static func random() -> LedRgb {
        return LedRgb(red: Float(arc4random()) / Float(UINT32_MAX),
                      green: Float(arc4random()) / Float(UINT32_MAX),
                      blue: Float(arc4random()) / Float(UINT32_MAX))
    }
}