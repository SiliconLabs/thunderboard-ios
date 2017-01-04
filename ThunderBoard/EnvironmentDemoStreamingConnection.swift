//
//  EnvironmentDemoStreamingConnection.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol EnvironmentDemoStreamingDataSource : class {
    func currentEnvironmentData() -> EnvironmentData?
}

class EnvironmentDemoStreamingConnection : DemoStreamingConnection {
    
    weak var dataSource: EnvironmentDemoStreamingDataSource?

    override func demoType() -> String {
        return "environment"
    }
    
    override func sampleDemoData() -> [DemoStreamingDataPoint]? {
        
        guard let sample = self.dataSource?.currentEnvironmentData() else {
            return nil
        }
        
        var data = Dictionary<String, AnyObject>()
        
        data["temperature"] = sample.temperature as AnyObject?
        data["humidity"] = sample.humidity as AnyObject?
        data["ambientLight"] = sample.ambientLight as AnyObject?
        data["uvIndex"] = sample.uvIndex as AnyObject?

        if let co2 = sample.co2 {
            if co2.enabled, let value = co2.value {
                data["co2"] = value as AnyObject?
            }
        }
        
        if let voc = sample.voc {
            if voc.enabled, let value = voc.value {
                data["voc"] = value as AnyObject?
            }
        }
        
        if let sound = sample.sound {
            data["sound"] = sound as AnyObject?
        }
        
        if let pressure = sample.pressure {
            data["pressure"] = pressure as AnyObject?
        }
        
        let path = "environment/data"
        let dataPoint = DemoStreamingDataPoint(path: path, timestamp: String(Date.tb_currentTimestamp), data: data as AnyObject)
        return [ dataPoint ]
    }
    
    override func reportingFrequency() -> TimeInterval {
        return TimeInterval(3)
    }
}
