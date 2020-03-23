//
//  MotionBoardDemoViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
import SceneKit

class MotionBoardDemoViewController : MotionDemoViewController {
    let settings = ThunderboardSettings()
    
    override func setupModel() {
        
        switch settings.motionDemoModel {
        case .board:
            let scaleFactor: Float = 2.0
            let identity = SCNMatrix4Identity
            let scale = SCNMatrix4Scale(identity, scaleFactor, scaleFactor, scaleFactor)

            var initialOrientation = SCNMatrix4Rotate(scale, 0, 1, 0, 0)
            initialOrientation = SCNMatrix4Rotate(initialOrientation, -.pi/2, 0, 1, 0)
            
            motionView.setModelScene("Thunderboard_React_031716_obj.obj", initialOrientation: initialOrientation)
        case .car:
            let scaleFactor: Float = 0.05
            let identity = SCNMatrix4Identity
            let scale = SCNMatrix4Scale(identity, scaleFactor, scaleFactor, scaleFactor)
            
            var initialOrientation = SCNMatrix4Rotate(scale, .pi/2, 1, 0, 0)
            initialOrientation = SCNMatrix4Rotate(initialOrientation, .pi/2, 0, 1, 0)

            motionView.setModelScene("SL_Derby_Assembly_1116_centered.obj", initialOrientation: initialOrientation)
        }
        
    }
    
    override func modelTranformMatrixForOrientation(_ orientation: ThunderboardInclination) -> SCNMatrix4 {
        let modelIdentity = motionView.modelIdentity
        
        if #available(iOS 13, *) {
            var transform = SCNMatrix4Rotate(modelIdentity!, -orientation.x.tb_toRadian(), 1, 0, 0)
            transform = SCNMatrix4Rotate(transform, orientation.y.tb_toRadian(), 0, 0, 1)
            transform = SCNMatrix4Rotate(transform, orientation.z.tb_toRadian(), 0, 1, 0)
            return transform
        } else {
            var transform = SCNMatrix4Rotate(modelIdentity!, -orientation.x.tb_toRadian(), 1, 0, 0)
            transform = SCNMatrix4Rotate(transform, -orientation.y.tb_toRadian(), 0, 1, 0)
            transform = SCNMatrix4Rotate(transform, orientation.z.tb_toRadian(), 0, 0, 1)
            return transform
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch settings.motionDemoModel {
        case .board:
            let cell: MotionCell = tableView.dequeueReusableCell(withIdentifier: "MotionCellBoard") as! MotionCell
            motionDemoView = cell.motionView
            setupModel()
            return cell
        case .car:
            let cell: MotionCell = tableView.dequeueReusableCell(withIdentifier: "MotionCellCar") as! MotionCell
            motionDemoView = cell.motionView
            setupModel()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch settings.motionDemoModel {
        case .board:
            return 422.0
        case .car:
            return 472.0
        }
    }
}
