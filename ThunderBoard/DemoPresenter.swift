//
//  DemoPresenter.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol DemoPresenter {
    func showIoDemo(connection: IoDemoConnection)
    func showMotionDemo(connection: MotionDemoConnection)
    func showEnvironmentDemo(connection: EnvironmentDemoConnection)
}