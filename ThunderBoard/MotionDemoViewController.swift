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
    
    fileprivate var calibrationAlert: UIAlertController?
    
    fileprivate let calibrationTitle    = "Calibrating"
    fileprivate let calibrationMessage  = "Please ensure the Thunderboard is stationary during calibration"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tb_setNavigationBarStyleForDemo(.motion)
        setupUnitsLabels()
        setupWheel()
        updateModelOrientation(ThunderboardInclination(x: 0, y: 0, z: 0), animated: false)
        interaction.updateView()
    }
    
    func setupModel() {
        // no-op - implemented in subclasses
    }
    
    func modelTranformMatrixForOrientation(_ orientation: ThunderboardInclination) -> SCNMatrix4 {
        // no-op - implemented in subclasses to account for model orientation deltas
        return motionView.modelIdentity
    }

    //MARK: - MotionDemoInteractionOutput
    
    func updateOrientation(_ orientation: ThunderboardInclination) {
        let degrees = " °"
        self.motionView.orientationXValue?.text = orientation.x.tb_toString(0)! + degrees
        self.motionView.orientationYValue?.text = orientation.y.tb_toString(0)! + degrees
        self.motionView.orientationZValue?.text = orientation.z.tb_toString(0)! + degrees
        
        updateModelOrientation(orientation, animated: true)
    }
    
    func updateAcceleration(_ vector: ThunderboardVector) {
        let gravity = " g"
        
        self.motionView.accelerationXValue?.text = vector.x.tb_toString(2, minimumDecimalPlaces: 2)!
        self.motionView.accelerationXValue?.text = vector.x.tb_toString(2, minimumDecimalPlaces: 2)! + gravity
        self.motionView.accelerationYValue?.text = vector.y.tb_toString(2, minimumDecimalPlaces: 2)! + gravity
        self.motionView.accelerationZValue?.text = vector.z.tb_toString(2, minimumDecimalPlaces: 2)! + gravity
    }
    
    func updateWheel(_ diameter: Meters) {
        let settings = ThunderboardSettings()
        switch settings.measurement {
        case .metric:
            let diameterInCentimeters: Centimeters = diameter * 100
            self.motionView.wheelDiameterValue?.text = diameterInCentimeters.tb_toString(2)! + " cm"
        case .imperial:
            let diameterInInches = diameter.tb_toInches()
            self.motionView.wheelDiameterValue?.text = diameterInInches.tb_toString(2)! + "\""
        }
    }
    
    func updateLocation(_ distance: Float, speed: Float, rpm: Float, totalRpm: UInt) {
        let settings = ThunderboardSettings()
        switch settings.measurement {
        case .metric:
            self.motionView.distanceValue?.text = distance.tb_toString(1)
            self.motionView.speedValue?.text = speed.tb_toString(1)
        case .imperial:
            self.motionView.distanceValue?.text = distance.tb_toFeet().tb_toString(1)
            self.motionView.speedValue?.text = speed.tb_toFeet().tb_toString(1)
        }
        self.motionView.rpmValue?.text = rpm.tb_toString(0)
        self.motionView.totalRpmValue?.text = String(totalRpm)
    }
    
    func updateLedColor(_ on: Bool, color: LedRgb) {
        updateModelLedColor(on ? color.uiColor : StyleColor.mediumGray)
    }
    
    func deviceCalibrating(_ isCalibrating: Bool) {
        if isCalibrating {
            if self.calibrationAlert == nil {
                self.calibrationAlert = UIAlertController(title: calibrationTitle, message: calibrationMessage, preferredStyle: .alert)
                self.present(self.calibrationAlert!, animated: true, completion: nil)
            }
        } else {
            guard self.calibrationAlert != nil else { return }
            
            // Call dismiss on self because calling it on UIAlertController does not produce a completion call
            self.dismiss(animated: true, completion: {
                let alertController = UIAlertController(title: "Calibration successful", message: nil, preferredStyle: .alert)

                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)

                self.present(alertController, animated: true, completion: nil)
            })
            self.calibrationAlert = nil
        }
    }
    
    //MARK: - Actions
    
    @IBAction func calibrateButtonPressed(_ sender: AnyObject) {
        self.interaction.calibrate()
    }
    
    //MARK: - Private
    
    fileprivate func setupUnitsLabels() {
        let settings = ThunderboardSettings()
        
        switch settings.measurement {
        case .metric:
            self.motionView.distanceValueLabel?.text = "m"
            self.motionView.speedValueLabel?.text = "m/s"
        case .imperial:
            self.motionView.distanceValueLabel?.text = "ft"
            self.motionView.speedValueLabel?.text = "ft/s"
        }
        
        self.motionView.rpmValueLabel?.text = "rpm"
        self.motionView.totalRpmValueLabel?.text = "total revolutions"
    }

    fileprivate func setupWheel() {
        let diameter = interaction.wheelDiameter()
        self.updateWheel(diameter)
    }
    
    fileprivate func updateModelOrientation(_ orientation : ThunderboardInclination, animated: Bool) {
        let finalTransform = modelTranformMatrixForOrientation(orientation)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = animated ? 0.1 : 0.0
        motionView.scene.rootNode.childNodes.first?.transform = finalTransform
        SCNTransaction.commit()
    }
    
    fileprivate func updateModelLedColor(_ color: UIColor) {
        ledMaterials.forEach { (material) in
            material.diffuse.contents = color
            material.emission.contents = color
        }
    }
}
