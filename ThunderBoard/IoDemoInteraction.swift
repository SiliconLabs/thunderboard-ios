//
//  IODemoInteraction.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol IoDemoInteractionOutput : class {
    func showButtonState(_ button: Int, pressed: Bool)
    func showLedState(_ led: Int, state: LedState)
    func disableRgb()
}

class IoDemoInteraction : DemoStreamingInteraction, DemoStreamingOutput, IoDemoConnectionDelegate, IoDemoStreamingDataSource {
    
    fileprivate weak var output: IoDemoInteractionOutput?
    fileprivate var connection: IoDemoConnection?

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
        guard let connection = connection else {
            return
        }
        
        for i in 0 ..< connection.numberOfSwitches {
            buttonPressed(i, pressed: connection.isSwitchPressed(i))
        }
        
        for i in 0 ..< connection.numberOfLeds {
            updatedLed(i, state: connection.ledState(i))
        }

        if connection.capabilities.contains(.rgbOutput) == false {
            output?.disableRgb()
        }
    }
    
    func toggleLed(_ ledNum: Int) {
        guard let connection = connection else {
            return
        }
        
        let state = connection.ledState(ledNum)
        connection.setLed(ledNum, state: state.toggle())
    }
    
    func setColor(_ index: Int, color: LedRgb) {
        guard let connection = connection else {
            return
        }
        
        let state = connection.ledState(index).setColor(color)
        connection.setLed(index, state: state)
    }
    
    //MARK: IoDemoConnectionDelegate
    
    func demoDeviceDisconnected() {
        streamingConnection?.stopStreaming()
    }
    
    func buttonPressed(_ button: Int, pressed: Bool) {
        output?.showButtonState(button, pressed: pressed)
    }
    
    func updatedLed(_ led: Int, state: LedState) {
        output?.showLedState(led, state: state)
    }
    
    //MARK:- IoDemoStreamingDataSource
    
    func currentInputStates() -> [Bool] {
        guard let connection = connection else {
            log.error("Connection to device is invalid")
            return []
        }
        
        return [
            connection.isSwitchPressed(0),  // TODO WIP Sense: hardcoded number of inputs
            connection.isSwitchPressed(1)
        ]
    }
    
    func currentOutputStates() -> [LedState] {
        guard let connection = connection else {
            log.error("Connection to device is invalid")
            return []
        }
        
        return [
            connection.ledState(0),   // TODO WIP Sense: hardcoded number of outputs
            connection.ledState(1)
        ]
    }
}
