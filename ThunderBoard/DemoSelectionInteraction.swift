//
//  DemoSelectionInteraction.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol DemoSelectionInteractionOutput: class {
    func showConfiguringDemo(_ demo: ThunderboardDemo)
    func enableDemoHistory(_ enabled: Bool)
}

class DemoSelectionInteraction: DemoConfigurationDelegate {
    
    var demoPresenter: DemoPresenter?
    var historyPresenter: DemoHistoryPresenter?
    var settingsPresenter: SettingsPresenter?
    fileprivate var demoConfiguration: DemoConfiguration?
    
    weak var output: DemoSelectionInteractionOutput?
    var configuringDemo: ThunderboardDemo?
    
    //MARK:- Public
    
    init(demoConfiguration: DemoConfiguration?,  output: DemoSelectionInteractionOutput?) {
        self.demoConfiguration = demoConfiguration
        self.output = output
        
        let enableHistory = demoConfiguration?.deviceIdentifier != nil
        output?.enableDemoHistory(enableHistory)
    }
    
    func configureForDemo(_ demo: ThunderboardDemo) {
        
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
    
    func deviceIdentifierUpdated(_ deviceId: DeviceId) {
        output?.enableDemoHistory(true)
    }
    
    // IO
    func configuringIoDemo() {
        self.configuringDemo = .io
        self.output?.showConfiguringDemo(.io)
    }
    
    func ioDemoReady(_ connection: IoDemoConnection) {
        self.configuringDemo = nil
        demoPresenter?.showIoDemo(connection)
    }
    
    
    // Motion
    
    func configuringMotionDemo() {
        self.configuringDemo = .motion
        self.output?.showConfiguringDemo(.motion)
    }
    
    func motionDemoReady(_ connection: MotionDemoConnection) {
        self.configuringDemo = nil
        demoPresenter?.showMotionDemo(connection)
    }

    
    // Environment
    
    func configuringEnvironmentDemo() {
        self.configuringDemo = .environment
        self.output?.showConfiguringDemo(.environment)
    }
    
    func environmentDemoReady(_ connection: EnvironmentDemoConnection) {
        self.configuringDemo = nil
        demoPresenter?.showEnvironmentDemo(connection)
    }
    
    
    // Reset
    
    func demoConfigurationReset() {
        log.info("demo configuration reset")
    }
}
