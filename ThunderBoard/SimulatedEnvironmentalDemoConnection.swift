//
//  SimulatedEnvironmentDemo.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class SimulatedEnvironmentDemoConnection : EnvironmentDemoConnection {
    
    var device: Device
    weak var connectionDelegate: EnvironmentDemoConnectionDelegate?
    var updateTimer: WeakTimer?
    
    init(device: SimulatedDevice) {
        self.device = device

        updateTimer = WeakTimer.scheduledTimer(0.5, repeats: true, action: { [weak self] () -> Void in
            self?.notifyLatestData()
        })
    }

    private func notifyLatestData() {
        var data = EnvironmentData()
        data.ambientLight = 999999
        data.humidity = 26
        data.uvIndex = 1.2
        data.temperature = 32
        self.connectionDelegate?.updatedEnvironmentData(data)
    }
}