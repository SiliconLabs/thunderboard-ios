//
//  MotionDemoViewController.swift
//  Thunderboard
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
    var ledMaterials: [SCNMaterial] = []
    
    private var calibrationAlert: UIAlertController?
    
    private let calibrationTitle    = "Calibrating"
    private let calibrationMessage  = "Please ensure the Thunderboard is stationary during calibration"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tb_setNavigationBarStyleForDemo(.Motion)
        setupUnitsLabels()
        setupWheel()
        updateModelOrientation(ThunderboardInclination(x: 0, y: 0, z: 0), animated: false)
        interaction.updateView()
    }
    
    func setupModel() {
        // no-op - implemented in subclasses
    }
    
    func modelTranformMatrixForOrientation(orientation: ThunderboardInclination) -> SCNMatrix4 {
        // no-op - implemented in subclasses to account for model orientation deltas
        return motionView.modelIdentity
    }

    //MARK: - MotionDemoInteractionOutput
    
    func updateOrientation(orientation: ThunderboardInclination) {
        let degrees = " °"
        self.motionView.orientationXValue?.text = orientation.x.tb_toString(0)! + degrees
        self.motionView.orientationYValue?.text = orientation.y.tb_toString(0)! + degrees
        self.motionView.orientationZValue?.text = orientation.z.tb_toString(0)! + degrees
        
        updateModelOrientation(orientation, animated: true)
    }
    
    func updateAcceleration(vector: ThunderboardVector) {
        let gravity = " g"
        
        self.motionView.accelerationXValue?.text = vector.x.tb_toString(2, minimumDecimalPlaces: 2)!
        self.motionView.accelerationXValue?.text = vector.x.tb_toString(2, minimumDecimalPlaces: 2)! + gravity
        self.motionView.accelerationYValue?.text = vector.y.tb_toString(2, minimumDecimalPlaces: 2)! + gravity
        self.motionView.accelerationZValue?.text = vector.z.tb_toString(2, minimumDecimalPlaces: 2)! + gravity
    }
    
    func updateWheel(diameter: Meters) {
        let settings = ThunderboardSettings()
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
        let settings = ThunderboardSettings()
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
    
    func updateLedColor(on: Bool, color: LedRgb) {
        updateModelLedColor(on ? color.uiColor : StyleColor.mediumGray)
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
        let settings = ThunderboardSettings()
        
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
    
    private func updateModelOrientation(orientation : ThunderboardInclination, animated: Bool) {
        let finalTransform = modelTranformMatrixForOrientation(orientation)
        
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(animated ? 0.1 : 0.0)
        motionView.scene.rootNode.childNodes.first?.transform = finalTransform
        SCNTransaction.commit()
    }
    
    private func updateModelLedColor(color: UIColor) {
        ledMaterials.forEach { (material) in
            material.diffuse.contents = color
            material.emission.contents = color
        }
    }
}
