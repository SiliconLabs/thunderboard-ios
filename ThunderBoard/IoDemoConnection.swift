//
//  IoDemoConnection.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol IoDemoConnection: DemoConnection {
    weak var connectionDelegate: IoDemoConnectionDelegate? { get set }

    var numberOfLeds: Int { get }
    var numberOfSwitches: Int { get }
    
    func setLed(led: Int, state: LedState)
    func ledState(led: Int) -> LedState

    func isSwitchPressed(switchIndex: Int) -> Bool
}

protocol IoDemoConnectionDelegate: class {
    func demoDeviceDisconnected()
    func buttonPressed(button: Int, pressed: Bool)
    func updatedLed(led: Int, state: LedState)
}

extension IoDemoConnection {
    var capabilities: Set<DeviceCapability> {
        let ioDemoCapabilities: Set<DeviceCapability> = [
            .DigitalInput,
            .DigitalOutput,
            .RGBOutput
        ]
        
        let enabledDeviceCapabilities = device.capabilities.filter({ (capability) -> Bool in
            if device.model != .Sense {
                return true
            }
            
            // Disable RGB on coin cell power
            switch capability {
            case .RGBOutput:
                switch device.power {
                case .Unknown, .CoinCell:
                    return false
                case .USB, .AA, .GenericBattery:
                    return true
                }
                
            default:
                return true
            }
        })
        
        return ioDemoCapabilities.intersect(enabledDeviceCapabilities)
    }
}