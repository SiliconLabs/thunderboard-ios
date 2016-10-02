//
//  MotionDemoInteraction.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol MotionDemoInteractionOutput : class {
    func updateOrientation(orientation: ThunderboardInclination)
    func updateAcceleration(acceleration: ThunderboardVector)
    func updateWheel(diameter: Meters)
    func updateLocation(distance: Float, speed: Float, rpm: Float, totalRpm: UInt)
    func updateLedColor(on: Bool, color: LedRgb)
    func deviceCalibrating(isCalibrating: Bool)
}

class MotionDemoInteraction : DemoStreamingInteraction, MotionDemoConnectionDelegate, DemoStreamingOutput, MotionDemoStreamingDataSource {

    var streamingConnection: DemoStreamingConnection?
    weak var streamingOutput: DemoStreamingInteractionOutput?
    weak var streamSharePresenter: DemoStreamSharePresenter?

    private weak var output: MotionDemoInteractionOutput?
    private var connection: MotionDemoConnection?
    
    private static let defaultWheelSize: Meters = 0.0301

    private var acceleration = ThunderboardVector()
    private var orientation = ThunderboardInclination()
    private var position = ThunderboardWheel(diameter: defaultWheelSize)
    private var calibrating = false
    
    private var calibrationComplete: (() -> Void)?
    private var resetOrientationComplete: (() -> Void)?
    private var resetRevolutionsComplete: (() -> Void)?
    private var calibrationTimer: NSTimer?
    
    //MARK: - Public
    
    init(output: MotionDemoInteractionOutput?, demoConnection: MotionDemoConnection) {
        self.output = output
        self.connection = demoConnection
        self.connection?.connectionDelegate = self
    }
    
    func updateView() {
        output?.deviceCalibrating(calibrating)
        
        orientationUpdated(orientation)
        accelerationUpdated(acceleration)
        rotationUpdated(position.revolutionsSinceConnecting, elapsedTime: position.secondsSinceConnecting)
        
        connection?.readLedColor()
    }
    
    func calibrate() {
        
        guard let connection = connection else {
            return
        }
        
        calibrating = true
        output?.deviceCalibrating(calibrating)
        
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        // Start calibration process (this may take up to 10 seconds)
        let calibration = queue.tb_addAsyncOperationBlock("calibration") { [weak self] (operation: AsyncOperation) -> Void in
            self?.calibrationComplete = { operation.done() }
            self?.connection?.startCalibration()
        }
        
        // Reset Orientation
        let orientation = queue.tb_addAsyncOperationBlock("orientation") { [weak self] (operation: AsyncOperation) -> Void in
            self?.resetOrientationComplete = { operation.done() }
            self?.connection?.resetOrientation()
        }
        
        
        // Notify VC
        let finished = queue.tb_addAsyncOperationBlock("finished") { [weak self] (operation: AsyncOperation) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.calibrating = false
                strongSelf.output?.deviceCalibrating(strongSelf.calibrating)
                operation.done()
            })
        }

        orientation.addDependency(calibration)
        finished.addDependency(orientation)
        finished.addDependency(calibration)

        // Reset Revolutions - only if cycling service is available
        if connection.capabilities.contains(.Revolutions) {
            let revolutions = queue.tb_addAsyncOperationBlock("revolutions") { [weak self] (operation: AsyncOperation) -> Void in
                self?.resetRevolutionsComplete = { operation.done() }
                self?.connection?.resetRevolutions()
            }
            
            revolutions.addDependency(calibration)
            revolutions.addDependency(orientation)
            finished.addDependency(revolutions)
        }

        queue.suspended = false
    }
    
    //MARK: - MotionDemoStreamingDataSource
    
    func currentAcceleration() -> ThunderboardVector {
        return acceleration
    }
    
    func currentOrientation() -> ThunderboardInclination {
        return orientation
    }
    
    func currentPosition() -> ThunderboardWheel {
        return position
    }
    
    func wheelDiameter() -> Meters {
        return position.diameter
    }
    
    //MARK: - MotionDemoConnectionDelegate
    
    func demoDeviceDisconnected() {
        streamingConnection?.stopStreaming()
        
        // If calibration is in-progress, trigger completion
        finishedCalbration()
        finishedOrientationReset()
        finishedRevolutionsReset()
    }
    
    func startedCalibration() {
        log.info("Calibration Started")
    }
    
    func finishedCalbration() {
        log.info("Calibration Finished")
        self.calibrationComplete?()
        self.calibrationComplete = nil
    }
    
    func startedOrientationReset() {
        log.info("Orientation Reset Started")
    }
    
    func finishedOrientationReset() {
        log.info("Orientation Reset Finished")
        self.resetOrientationComplete?()
        self.resetOrientationComplete = nil
    }
    
    func startedRevolutionsReset() {
        log.info("Revolutions Reset Started")
    }
    
    func finishedRevolutionsReset() {
        log.info("Revolutions Reset Finished")
        self.resetRevolutionsComplete?()
        self.resetRevolutionsComplete = nil
    }
    
    func orientationUpdated(inclination: ThunderboardInclination) {
        orientation = inclination
        output?.updateOrientation(inclination)
    }
    
    func accelerationUpdated(vector: ThunderboardVector) {
        acceleration = vector
        output?.updateAcceleration(vector)
    }
    
    func ledColorUpdated(on: Bool, color: LedRgb) {
        output?.updateLedColor(on, color: color)
    }
    
    func rotationUpdated(revolutions: UInt, elapsedTime: NSTimeInterval) {
        position.updateRevolutions(revolutions, cumulativeSecondsSinceConnecting: elapsedTime)
        let speed    = position.speedInMetersPerSecond
        let distance = position.distance
        let rpm      = position.rpm
        let total    = position.revolutionsSinceConnecting
        output?.updateLocation(distance, speed: speed, rpm: rpm, totalRpm: total)
    }
}
