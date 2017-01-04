//
//  IoDemoStreamingConnection.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol IoDemoStreamingDataSource : class {
    func currentInputStates() -> [Bool]     // state of buttons
    func currentOutputStates() -> [LedState]    // state of LEDs
}

class IoDemoStreamingConnection : DemoStreamingConnection {

    weak var dataSource: IoDemoStreamingDataSource?

    //MARK:- Public

    override func demoType() -> String {
        return "io"
    }
    
    override func sampleDemoData() -> [DemoStreamingDataPoint]? {
        guard let dataSource = dataSource else {
            assert(false)
            return nil
        }
        
        var data:[String: AnyObject] = Dictionary<String, AnyObject>()
        let inputs = dataSource.currentInputStates()
        let outputs = dataSource.currentOutputStates()
        
        for (index, input) in inputs.enumerated() {
            data["sw\(index)"] = input ? Int(1) as AnyObject? : Int(0) as AnyObject?
        }
        
        
        // ledb, ledg
        let labels = [ "ledb", "ledg" ]
        for (index, output) in outputs.enumerated() {
            if index < labels.count {
                data[labels[index]] = output.on ? Int(1) as AnyObject? : Int(0) as AnyObject?
            }
        }
        
        let path = "io/data"
        let dataPoint = DemoStreamingDataPoint(path: path,  timestamp: String(Date.tb_currentTimestamp), data: data as AnyObject)
        return [dataPoint]
    }

}
