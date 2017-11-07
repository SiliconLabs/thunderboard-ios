//
//  MotionDemoStreamingConnection.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import Firebase

protocol MotionDemoStreamingDataSource : class {
    
    func currentAcceleration() -> ThunderboardVector
    func currentOrientation() -> ThunderboardInclination
    func currentPosition() -> ThunderboardWheel
}

class MotionDemoStreamingConnection : DemoStreamingConnection {

    weak var dataSource: MotionDemoStreamingDataSource?
    
    override func demoType() -> String {
        return "motion"
    }
    
    override func sampleFrequency() -> TimeInterval {
        return 0.1
    }
    
    override func sampleDemoData() -> [DemoStreamingDataPoint]? {
        
        guard let acceleration = self.dataSource?.currentAcceleration(),
            let orientation = self.dataSource?.currentOrientation(),
            let position = self.dataSource?.currentPosition() else {

            return nil
        }

        var data:[String: AnyObject] = Dictionary<String, AnyObject>()
        
        data["ax"] = acceleration.x as AnyObject?
        data["ay"] = acceleration.y as AnyObject?
        data["az"] = acceleration.z as AnyObject?
        
        data["ox"] = orientation.x as AnyObject?
        data["oy"] = orientation.y as AnyObject?
        data["oz"] = orientation.z as AnyObject?
        
        data["speed"] = position.speedInMetersPerSecond as AnyObject?
        data["distance"] = position.distance as AnyObject?

        let path = "motion/data"
        let dataPoint = DemoStreamingDataPoint(path: path,  timestamp: String(Date.tb_currentTimestamp), data: data)
        return [dataPoint]
    }
}
