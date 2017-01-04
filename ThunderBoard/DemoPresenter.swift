//
//  DemoPresenter.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol DemoPresenter {
    func showIoDemo(_ connection: IoDemoConnection)
    func showMotionDemo(_ connection: MotionDemoConnection)
    func showEnvironmentDemo(_ connection: EnvironmentDemoConnection)
}
