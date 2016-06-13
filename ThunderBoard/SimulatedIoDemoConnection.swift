//
//  SimulatedIoDemoConnection.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class SimulatedIoDemoConnection : IoDemoConnection {
    
    var device: Device
    weak var connectionDelegate: IoDemoConnectionDelegate?
    
    init(device: SimulatedDevice) {
        self.device = device
    }
    
    // For demo, switches will shadow the LEDs
    private var leds: [Bool] = [false, false]
    func setLed(led: UInt, on: Bool) {
        let index = Int(led)
        if index < leds.count {
            leds[index] = on
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                self.connectionDelegate?.buttonPressed(index, pressed: on)
            }

            self.connectionDelegate?.ledOn(UInt(index), on: on)
        }
    }
    
    func isLedOn(led: UInt) -> Bool {
        let index = Int(led)
        if index < leds.count {
            return leds[index]
        }
        
        return false
    }
    
    func isSwitchPressed(switchIndex: UInt) -> Bool {
        let index = Int(switchIndex)
        if index < leds.count {
            return leds[index]
        }
        
        return false
    }
    
}