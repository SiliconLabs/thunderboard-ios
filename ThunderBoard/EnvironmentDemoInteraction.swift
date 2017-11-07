//
//  EnvironmentDemoInteraction.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol EnvironmentDemoInteractionOutput : class {
    func updatedEnvironmentData(_ data: EnvironmentData, capabilities: Set<DeviceCapability>)
}

class EnvironmentDemoInteraction : DemoStreamingInteraction, DemoStreamingOutput, EnvironmentDemoConnectionDelegate, EnvironmentDemoStreamingDataSource {

    fileprivate weak var output: EnvironmentDemoInteractionOutput?
    fileprivate var connection: EnvironmentDemoConnection?
    
    var streamingConnection: DemoStreamingConnection?
    weak var streamingOutput: DemoStreamingInteractionOutput?
    weak var streamSharePresenter: DemoStreamSharePresenter?

    fileprivate var currentData: EnvironmentData = EnvironmentData()
    fileprivate let capabilities: Set<DeviceCapability>
    
    //MARK: - Public
    
    init(output: EnvironmentDemoInteractionOutput?, demoConnection: EnvironmentDemoConnection) {
        self.capabilities = demoConnection.capabilities
        self.output = output
        self.connection = demoConnection
        self.connection?.connectionDelegate = self
    }
    
    func updateView() {
        updatedEnvironmentData(currentData)
    }

    func resetTamperState() {
        connection?.resetTamper()
    }

    //MARK: - EnvironmentDemoConnectionDelegate
    
    func demoDeviceDisconnected() {
        streamingConnection?.stopStreaming()
    }
    
    func updatedEnvironmentData(_ data: EnvironmentData) {
        currentData = data
        self.output?.updatedEnvironmentData(currentData, capabilities: capabilities)
    }
    
    //MARK: - EnvironmentDemoStreamingDataSource
    
    func currentEnvironmentData() -> EnvironmentData? {
        return currentData
    }
}
