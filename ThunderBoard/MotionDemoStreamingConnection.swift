//
//  MotionDemoStreamingConnection.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import Firebase

protocol MotionDemoStreamingDataSource : class {
    
    func currentAcceleration() -> ThunderBoardVector
    func currentOrientation() -> ThunderBoardInclination
    func currentPosition() -> ThunderBoardWheel
}

class MotionDemoStreamingConnection : DemoStreamingConnection {

    weak var dataSource: MotionDemoStreamingDataSource?
    
    override func demoType() -> String {
        return "motion"
    }
    
    override func sampleFrequency() -> NSTimeInterval {
        return 0.1
    }
    
    override func sampleDemoData() -> [DemoStreamingDataPoint]? {
        
        guard let acceleration = self.dataSource?.currentAcceleration(),
            orientation = self.dataSource?.currentOrientation(),
            position = self.dataSource?.currentPosition() else {

            return nil
        }

        var data:[String: AnyObject] = Dictionary<String, AnyObject>()
        
        data["ax"] = acceleration.x
        data["ay"] = acceleration.y
        data["az"] = acceleration.z
        
        data["ox"] = orientation.x
        data["oy"] = orientation.y
        data["oz"] = orientation.z
        
        data["speed"] = position.speedInMetersPerSecond
        data["distance"] = position.distance

        let path = "motion/data"
        let dataPoint = DemoStreamingDataPoint(path: path,  timestamp: String(NSDate.tb_currentTimestamp), data: data)
        return [dataPoint]
    }
}