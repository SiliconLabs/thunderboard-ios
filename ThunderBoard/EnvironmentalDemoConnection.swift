//
//  EnvironmentDemoConnection.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol EnvironmentDemoConnection: DemoConnection {
    weak var connectionDelegate: EnvironmentDemoConnectionDelegate? { get set }
}

protocol EnvironmentDemoConnectionDelegate: class {
    func demoDeviceDisconnected()
    func updatedEnvironmentData(data: EnvironmentData)
}

extension EnvironmentDemoConnection {
    var capabilities: Set<DeviceCapability> {
        let environmentCapabilities: Set<DeviceCapability> = [
            .Temperature,
            .UVIndex,
            .AmbientLight,
            .Humidity,
            .SoundLevel,
            .AirQualityCO2,
            .AirQualityVOC,
            .AirPressure,
        ]
        
        // Filter AirQuality capabilities if the Sense board is on CoinCell power
        let enabledDeviceCapabilities = device.capabilities.filter({ (capability) -> Bool in
            if device.model != .Sense {
                return true
            }

            switch capability {
            case .AirQualityCO2: fallthrough
            case .AirQualityVOC:
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
        
        return environmentCapabilities.intersect(enabledDeviceCapabilities)
    }
}