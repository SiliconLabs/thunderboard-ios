//
//  DemoSelectionInteraction.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol DemoSelectionInteractionOutput: class {
    func showConfiguringDemo(demo: ThunderboardDemo)
    func enableDemoHistory(enabled: Bool)
}

class DemoSelectionInteraction: DemoConfigurationDelegate {
    
    var demoPresenter: DemoPresenter?
    var historyPresenter: DemoHistoryPresenter?
    var settingsPresenter: SettingsPresenter?
    private var demoConfiguration: DemoConfiguration?
    
    weak var output: DemoSelectionInteractionOutput?
    var configuringDemo: ThunderboardDemo?
    
    //MARK:- Public
    
    init(demoConfiguration: DemoConfiguration?,  output: DemoSelectionInteractionOutput?) {
        self.demoConfiguration = demoConfiguration
        self.output = output
        
        let enableHistory = demoConfiguration?.deviceIdentifier != nil
        output?.enableDemoHistory(enableHistory)
    }
    
    func configureForDemo(demo: ThunderboardDemo) {
        
        // prevent multiple configurations
        if configuringDemo != nil {
            return
        }
        
        demoConfiguration?.configureForDemo(demo)
    }
    
    func resetDemoConfiguration() {
        demoConfiguration?.resetDemoConfiguration()
    }
    
    func showHistory() {
        historyPresenter?.showHistory()
    }
    
    func showSettings() {
        settingsPresenter?.showSettings()
    }

    //MARK:- DemoConfigurationDelegate
    
    func deviceIdentifierUpdated(deviceId: DeviceId) {
        output?.enableDemoHistory(true)
    }
    
    // IO
    func configuringIoDemo() {
        self.configuringDemo = .IO
        self.output?.showConfiguringDemo(.IO)
    }
    
    func ioDemoReady(connection: IoDemoConnection) {
        self.configuringDemo = nil
        demoPresenter?.showIoDemo(connection)
    }
    
    
    // Motion
    
    func configuringMotionDemo() {
        self.configuringDemo = .Motion
        self.output?.showConfiguringDemo(.Motion)
    }
    
    func motionDemoReady(connection: MotionDemoConnection) {
        self.configuringDemo = nil
        demoPresenter?.showMotionDemo(connection)
    }

    
    // Environment
    
    func configuringEnvironmentDemo() {
        self.configuringDemo = .Environment
        self.output?.showConfiguringDemo(.Environment)
    }
    
    func environmentDemoReady(connection: EnvironmentDemoConnection) {
        self.configuringDemo = nil
        demoPresenter?.showEnvironmentDemo(connection)
    }
    
    
    // Reset
    
    func demoConfigurationReset() {
        log.info("demo configuration reset")
    }
}
