//
//  SimulatedIoDemoConnection.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class SimulatedIoDemoConnection : IoDemoConnection {
    
    var device: Device
    weak var connectionDelegate: IoDemoConnectionDelegate?
    
    // For demo, switches will shadow the LEDs
    var numberOfLeds: Int = 3
    var numberOfSwitches: Int = 2
    private var deviceState: [LedState] = []
    
    init(device: SimulatedDevice) {
        self.device = device

        deviceState.append(LedState.Digital(false, device.ledColor(0)))
        deviceState.append(LedState.Digital(false, device.ledColor(1)))
        deviceState.append(LedState.RGB(false, LedRgb(red: 0.90, green: 0.50, blue: 0)))
    }

    func setLed(led: Int, state: LedState) {
        let index = Int(led)
        if index < deviceState.count {
            deviceState[index] = state
            
            delay(0.5) {
                self.connectionDelegate?.buttonPressed(index, pressed: self.isSwitchPressed(index))
            }

            self.connectionDelegate?.updatedLed(led, state: state)
        }
    }
    
    func ledState(led: Int) -> LedState {
        return deviceState[led]
    }
    
    func isSwitchPressed(switchIndex: Int) -> Bool {
        let state = ledState(switchIndex)
        switch state {
        case .Digital(let on, _):
            return on
        case .RGB(let on, _):
            return on
        }
    }
}
