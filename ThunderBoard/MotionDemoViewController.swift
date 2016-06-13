//
//  MotionDemoViewController.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
import SceneKit

class MotionDemoViewController : DemoViewController, MotionDemoInteractionOutput {
    
    var motionView: MotionDemoView {
        return self.view as! MotionDemoView
    }
    var interaction: MotionDemoInteraction!
    
    private var calibrationAlert: UIAlertController?
    
    private let calibrationTitle    = "Calibrating"
    private let calibrationMessage  = "Please ensure the ThunderBoard is stationary during calibration"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModel()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tb_setNavigationBarStyleForDemo(.Motion)
        setupUnitsLabels()
        setupWheel()
        updateModelOrientation(ThunderBoardInclination(x: 0, y: 0, z: 0), animated: false)
    }
    
    func setupModel() {
        // no-op - implemented in subclasses
    }
    
    func modelTranformMatrixForOrientation(orientation: ThunderBoardInclination) -> SCNMatrix4 {
        // no-op - implemented in subclasses to account for model orientation deltas
        return motionView.modelIdentity
    }

    //MARK: - MotionDemoInteractionOutput
    
    func updateOrientation(orientation: ThunderBoardInclination) {
        let degrees = " °"
        self.motionView.orientationXValue?.text = orientation.x.tb_toString(0)! + degrees
        self.motionView.orientationYValue?.text = orientation.y.tb_toString(0)! + degrees
        self.motionView.orientationZValue?.text = orientation.z.tb_toString(0)! + degrees
        
        updateModelOrientation(orientation, animated: true)
    }
    
    func updateAcceleration(vector: ThunderBoardVector) {
        let gravity = " g"
        self.motionView.accelerationXValue?.text = vector.x.tb_toString(1)! + gravity
        self.motionView.accelerationYValue?.text = vector.y.tb_toString(1)! + gravity
        self.motionView.accelerationZValue?.text = vector.z.tb_toString(1)! + gravity
    }
    
    func updateWheel(diameter: Meters) {
        let settings = ThunderBoardSettings()
        switch settings.measurement {
        case .Metric:
            let diameterInCentimeters: Centimeters = diameter * 100
            self.motionView.wheelDiameterValue?.text = diameterInCentimeters.tb_toString(2)! + " cm"
        case .Imperial:
            let diameterInInches = diameter.tb_toInches()
            self.motionView.wheelDiameterValue?.text = diameterInInches.tb_toString(2)! + "\""
        }
    }
    
    func updateLocation(distance: Float, speed: Float, rpm: Float, totalRpm: UInt) {
        let settings = ThunderBoardSettings()
        switch settings.measurement {
        case .Metric:
            self.motionView.distanceValue?.text = distance.tb_toString(1)
            self.motionView.speedValue?.text = speed.tb_toString(1)
        case .Imperial:
            self.motionView.distanceValue?.text = distance.tb_toFeet().tb_toString(1)
            self.motionView.speedValue?.text = speed.tb_toFeet().tb_toString(1)
        }
        self.motionView.rpmValue?.text = rpm.tb_toString(0)
        self.motionView.totalRpmValue?.text = String(totalRpm)
    }
    
    func deviceCalibrating(isCalibrating: Bool) {
        if isCalibrating {
            if self.calibrationAlert == nil {
                self.calibrationAlert = UIAlertController(title: calibrationTitle, message: calibrationMessage, preferredStyle: .Alert)
                self.presentViewController(self.calibrationAlert!, animated: true, completion: nil)
            }
        }
        else{
            self.calibrationAlert?.dismissViewControllerAnimated(true, completion: nil)
            self.calibrationAlert = nil
        }
    }
    
    //MARK: - Actions
    
    @IBAction func calibrateButtonPressed(sender: AnyObject) {
        self.interaction.calibrate()
    }
    
    //MARK: - Private
    
    private func setupUnitsLabels() {
        let settings = ThunderBoardSettings()
        
        switch settings.measurement {
        case .Metric:
            self.motionView.distanceValueLabel?.text = "m"
            self.motionView.speedValueLabel?.text = "m/s"
        case .Imperial:
            self.motionView.distanceValueLabel?.text = "ft"
            self.motionView.speedValueLabel?.text = "ft/s"
        }
        
        self.motionView.rpmValueLabel?.text = "rpm"
        self.motionView.totalRpmValueLabel?.text = "total revolutions"
    }

    private func setupWheel() {
        let diameter = interaction.wheelDiameter()
        self.updateWheel(diameter)
    }
    
    private func updateModelOrientation(orientation : ThunderBoardInclination, animated: Bool) {
        let finalTransform = modelTranformMatrixForOrientation(orientation)
        
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(animated ? 0.1 : 0.0)
        motionView.scene.rootNode.childNodes.first?.transform = finalTransform
        SCNTransaction.commit()
    }
}
