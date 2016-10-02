//
//  EnvironmentDemoInteraction.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol EnvironmentDemoInteractionOutput : class {
    func updatedEnvironmentData(data: EnvironmentData, capabilities: Set<DeviceCapability>)
}

class EnvironmentDemoInteraction : DemoStreamingInteraction, DemoStreamingOutput, EnvironmentDemoConnectionDelegate, EnvironmentDemoStreamingDataSource {

    private weak var output: EnvironmentDemoInteractionOutput?
    private var connection: EnvironmentDemoConnection?
    
    var streamingConnection: DemoStreamingConnection?
    weak var streamingOutput: DemoStreamingInteractionOutput?
    weak var streamSharePresenter: DemoStreamSharePresenter?

    private var currentData: EnvironmentData = EnvironmentData()
    private let capabilities: Set<DeviceCapability>
    
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
    
    //MARK: - EnvironmentDemoConnectionDelegate
    
    func demoDeviceDisconnected() {
        streamingConnection?.stopStreaming()
    }
    
    func updatedEnvironmentData(data: EnvironmentData) {
        currentData = data
        self.output?.updatedEnvironmentData(currentData, capabilities: capabilities)
    }
    
    //MARK: - EnvironmentDemoStreamingDataSource
    
    func currentEnvironmentData() -> EnvironmentData? {
        return currentData
    }
}