//
//  MotionBoardDemoViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
import SceneKit

class MotionBoardDemoViewController : MotionDemoViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Motion: Board"
    }
    
    override func setupModel() {

        let scaleFactor: Float = 2.0
        let identity = SCNMatrix4Identity
        let scale = SCNMatrix4Scale(identity, scaleFactor, scaleFactor, scaleFactor)

        var initialOrientation = SCNMatrix4Rotate(scale, 0, 1, 0, 0)
        initialOrientation = SCNMatrix4Rotate(initialOrientation, -Float(M_PI_2), 0, 1, 0)
        
        motionView.setModelScene("Thunderboard_React_031716_obj.obj", initialOrientation: initialOrientation)
    }
    
    override func modelTranformMatrixForOrientation(_ orientation: ThunderboardInclination) -> SCNMatrix4 {
        let modelIdentity = motionView.modelIdentity
        
        var transform = SCNMatrix4Rotate(modelIdentity!, -orientation.x.tb_toRadian(), 0, 0, 1)
        transform = SCNMatrix4Rotate(transform, -orientation.y.tb_toRadian(), 1, 0, 0)
        transform = SCNMatrix4Rotate(transform, orientation.z.tb_toRadian(), 0, 1, 0)
        
        return transform
    }
}
