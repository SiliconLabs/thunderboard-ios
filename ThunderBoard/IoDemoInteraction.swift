//
//  IODemoInteraction.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol IoDemoInteractionOutput : class {
    func showButtonState(button: Int, pressed: Bool)
    func showLedState(led: UInt, isOn: Bool)
}

class IoDemoInteraction : DemoStreamingInteraction, DemoStreamingOutput, IoDemoConnectionDelegate, IoDemoStreamingDataSource {
    
    private weak var output: IoDemoInteractionOutput?
    private var connection: IoDemoConnection?

    var streamingConnection: DemoStreamingConnection?
    weak var streamingOutput: DemoStreamingInteractionOutput?
    weak var streamSharePresenter: DemoStreamSharePresenter?

    //MARK: Public
    
    init(output: IoDemoInteractionOutput?, demoConnection: IoDemoConnection) {
        self.output = output
        self.connection = demoConnection
        self.connection?.connectionDelegate = self
    }
    
    func updateView() {
        ledOn(0, on: isLedOn(0))
        ledOn(1, on: isLedOn(1))
        buttonPressed(0, pressed: isSwitchPressed(0))
        buttonPressed(1, pressed: isSwitchPressed(1))
    }
    
    func toggleLed(ledNum: UInt) {
        let newLedState: Bool = !(connection?.isLedOn(ledNum))!
        connection?.setLed(ledNum, on: newLedState)
    }
    
    func isLedOn(ledIndex: UInt) -> Bool {
        return (connection?.isLedOn(ledIndex))!
    }
    
    func isSwitchPressed(switchIndex: UInt) -> Bool {
        return (connection?.isSwitchPressed(switchIndex))!
    }

    
    //MARK: IoDemoConnectionDelegate
    
    func demoDeviceDisconnected() {
        streamingConnection?.stopStreaming()
    }
    
    func buttonPressed(button: Int, pressed: Bool) {
        output?.showButtonState(button, pressed: pressed)
    }
    
    func ledOn(led: UInt, on: Bool) {
        output?.showLedState(led, isOn: on)
    }
    
    //MARK:- IoDemoStreamingDataSource
    
    func currentInputStates() -> [Bool] {
        guard let connection = connection else {
            log.error("Connection to device is invalid")
            return []
        }
        
        return [
            connection.isSwitchPressed(0),  // TODO: hardcoded number of inputs
            connection.isSwitchPressed(1)
        ]
    }
    
    func currentOutputStates() -> [Bool] {
        guard let connection = connection else {
            log.error("Connection to device is invalid")
            return []
        }
        
        return [
            connection.isLedOn(0),   // TODO: hardcoded number of outputs
            connection.isLedOn(1)
        ]
    }
}