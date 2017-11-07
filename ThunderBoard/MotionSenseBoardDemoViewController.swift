//
//  MotionBoardDemoViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
import SceneKit

class MotionSenseBoardDemoViewController : MotionDemoViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Motion"
    }
    
    override func setupModel() {

        let scaleFactor: Float = 0.75
        let identity = SCNMatrix4Identity
        let scale = SCNMatrix4Scale(identity, scaleFactor, scaleFactor, scaleFactor)

        var initialOrientation = SCNMatrix4Rotate(scale, 0, 1, 0, 0)
        initialOrientation = SCNMatrix4Rotate(initialOrientation, Float(M_PI_2), 1, 0, 0)

        motionView.setModelScene("TBSense_Rev_Lowpoly_2.obj", initialOrientation: initialOrientation)
        ledMaterials = locateMaterialsNamed([
            "thunderboardsense_lowpoly_007:lambert28sg",
            "thunderboardsense_lowpoly_007:lambert32sg",
            "lambert25sg",
            "lambert26sg",
        ])
    }
    
    override func modelTranformMatrixForOrientation(_ orientation: ThunderboardInclination) -> SCNMatrix4 {
        let modelIdentity = motionView.modelIdentity
        
        var transform = SCNMatrix4Rotate(modelIdentity!, -orientation.x.tb_toRadian(), 1, 0, 0)
        transform = SCNMatrix4Rotate(transform, -orientation.y.tb_toRadian(), 0, 1, 0)
        transform = SCNMatrix4Rotate(transform, orientation.z.tb_toRadian(), 0, 0, 1)
        
        return transform
    }
    
    // MARK: - Private
    
    fileprivate func locateMaterialsNamed(_ names: [String]) -> [SCNMaterial] {
        let lowercaseNames = names.map({ $0.lowercased() })
        func recurseNode(_ node: SCNNode) -> [SCNMaterial] {
            var results: [SCNMaterial] = []

            node.childNodes.forEach({ (child) in
                if let _ = child.geometry {
                    
                    child.childNodes.forEach({
                        results.append(contentsOf: recurseNode($0))
                    })
                    
                    child.geometry?.materials.forEach({ (material) in
                        guard let materialName = material.name?.lowercased() else {
                            return
                        }

                        if lowercaseNames.contains(materialName) {
                            results.append(material)
                        }
                    })
                }
                
                results.append(contentsOf: recurseNode(child))
            })
            
            return results
        }
        
        let results = recurseNode(motionView.scene.rootNode)
        log.debug("results: \(results)")
        return results
    }
}
