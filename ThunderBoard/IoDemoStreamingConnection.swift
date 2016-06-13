//
//  IoDemoStreamingConnection.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol IoDemoStreamingDataSource : class {
    func currentInputStates() -> [Bool]     // state of buttons
    func currentOutputStates() -> [Bool]    // state of LEDs
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
        
        for (index, input) in inputs.enumerate() {
            data["sw\(index)"] = input ? Int(1) : Int(0)
        }
        
        
        // ledb, ledg
        let labels = [ "ledb", "ledg" ]
        for (index, output) in outputs.enumerate() {
            if index < labels.count {
                data[labels[index]] = output ? Int(1) : Int(0)
            }
        }
        
        let path = "io/data"
        let dataPoint = DemoStreamingDataPoint(path: path,  timestamp: String(NSDate.tb_currentTimestamp), data: data)
        return [dataPoint]
    }

}