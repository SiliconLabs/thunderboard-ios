//
//  IoDemoConnection.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol IoDemoConnection: DemoConnection {
    weak var connectionDelegate: IoDemoConnectionDelegate? { get set }
    func setLed(led: UInt, on: Bool)
    func isLedOn(led: UInt) -> Bool
    
    func isSwitchPressed(switchIndex: UInt) -> Bool
}

protocol IoDemoConnectionDelegate: class {
    func demoDeviceDisconnected()
    func buttonPressed(button: Int, pressed: Bool)
    func ledOn(led: UInt, on: Bool)
}