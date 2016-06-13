//
//  EnvironmentDemoConnection.swift
//  ThunderBoard
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