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
        
        var data = Dictionary<String, Any>()
        
        data["temperature"] = sample.temperature as Any?
        data["humidity"] = sample.humidity as Any?
        data["ambientLight"] = sample.ambientLight as Any?
        data["uvIndex"] = sample.uvIndex as Any?

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

        if let hallEffectState = sample.hallEffectState {
            data["hallEffectState"] = hallEffectState.hashValue as AnyObject?
        }

        if let hallEffectFieldStrength = sample.hallEffectFieldStrength {
            data["hallEffectFieldStrength"] = hallEffectFieldStrength as AnyObject?
        }
        
        let path = "environment/data"
        let dataPoint = DemoStreamingDataPoint(path: path,  timestamp: String(Date.tb_currentTimestamp), data: data)
        return [dataPoint]
    }
    
    override func reportingFrequency() -> TimeInterval {
        return TimeInterval(3)
    }
}
