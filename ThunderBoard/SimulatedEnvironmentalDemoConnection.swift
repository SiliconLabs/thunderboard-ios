//
//  SimulatedEnvironmentDemo.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class SimulatedEnvironmentDemoConnection : EnvironmentDemoConnection {
    
    var device: Device
    weak var connectionDelegate: EnvironmentDemoConnectionDelegate?
    var updateTimer: WeakTimer?
    private var previous = EnvironmentData()
    
    private var co2Enabled = true
    private var vocEnabled = true
    
    // MARK:
    
    init(device: SimulatedDevice) {
        self.device = device

        updateTimer = WeakTimer.scheduledTimer(1.0, repeats: true, action: { [weak self] () -> Void in
            self?.notifyLatestData()
        })
    }

    // MARK:

    private func notifyLatestData() {
        var data = EnvironmentData()
        
        capabilities.forEach({
            switch $0 {
            case .AmbientLight:
                data.ambientLight = (previous.ambientLight ?? 10) + 10
            case .Humidity:
                data.humidity = (previous.humidity ?? 26) + 1
            case .UVIndex:
                data.uvIndex = (previous.uvIndex ?? 1.2) + 0.05
            case .Temperature:
                data.temperature = (previous.temperature ?? 0) + 0.3
            case .AirQualityVOC:
                data.voc = VolatileOrganicCompoundsReading(enabled: vocEnabled, value: AirQualityVOC((previous.voc?.value ?? 100) + 5))
            case .AirQualityCO2:
                data.co2 = CarbonDioxideReading(enabled: co2Enabled, value: AirQualityCO2((previous.co2?.value ?? 0) + 10))
            case .AirPressure:
                data.pressure = (previous.pressure ?? 980) + 1
            case .SoundLevel:
                data.sound = (previous.sound ?? 0) + 3
                
            default:
                break
            }
        })
        
        self.connectionDelegate?.updatedEnvironmentData(data)
        previous = data
    }
}