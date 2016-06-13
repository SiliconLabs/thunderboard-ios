//
//  DemoConfiguration.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol DemoConfiguration: class {
    var deviceIdentifier: DeviceId? { get }
    weak var configurationDelegate: DemoConfigurationDelegate? { get set }
    func configureForDemo(demo: ThunderBoardDemo)
    func resetDemoConfiguration()
}

protocol DemoConfigurationDelegate: class {
    
    func deviceIdentifierUpdated(deviceId: DeviceId)

    func configuringIoDemo()
    func ioDemoReady(connection: IoDemoConnection)
    
    func configuringMotionDemo()
    func motionDemoReady(connection: MotionDemoConnection)
    
    func configuringEnvironmentDemo()
    func environmentDemoReady(connection: EnvironmentDemoConnection)
    
    func demoConfigurationReset()
}