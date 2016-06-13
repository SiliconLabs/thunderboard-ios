//
//  SimulatedDevice.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class SimulatedDevice : Device, DemoConfiguration, CustomDebugStringConvertible {
    
    var name: String?
    var deviceIdentifier: DeviceId? {
        didSet {
            self.deviceIdentifierUpdated()
        }
    }
    var RSSI: Int?
    var batteryLevel: Int?
    var firmwareVersion: String?
    var connectionState: DeviceConnectionState {
        didSet {
            switch connectionState {
            case .Disconnected:
                break
            case .Connecting:
                break
            case .Connected:
                delay(1) {
                    self.batteryLevel = 95
                    self.firmwareVersion = "1.0.0";
                    self.notifyConnectedDelegate()
                }
                break
            }
        }
    }
    weak var connectedDelegate: ConnectedDeviceDelegate?
    
    weak var simulatedScanner: SimulatedDeviceScanner?
    
    weak var demoConnection: DemoConnection?
    
    init() {
        name = "Simulated"
        RSSI = -40
        connectionState = .Disconnected
        
        delay(2.0) {
            self.deviceIdentifier = DeviceId(100)
            self.notifyConnectedDelegate()
        }
    }
    
    private func notifyConnectedDelegate() {
        self.connectedDelegate?.connectedDeviceUpdated(self.name!, RSSI: self.RSSI, battery: self.batteryLevel, identifier: self.deviceIdentifier, firmwareVersion: self.firmwareVersion)
    }
    
    func demoConfiguration() -> DemoConfiguration {
        return self
    }
    
    typealias CalibrationCompletion = ( () -> Void )
    func startCalibration(completion: CalibrationCompletion?) {
        
        delay(5) {
            completion?()
        }
        
        // simulate a disconnect
//        delay(1) { [weak self] in
//            self?.simulateLostConnection()
//        }
    }
    
    var debugDescription: String {
        get { return "\(name): \(deviceIdentifier)" }
    }
    
    //MARK: - Private
    
    private func simulateLostConnection() {

        self.simulatedScanner?.simulateLostConnection(self)
    }
    
    //MARK: - DemoConfiguration
    
    weak var configurationDelegate: DemoConfigurationDelegate?
    func configureForDemo(demo: ThunderBoardDemo) {

        switch demo {
        case .IO:
            configureIoDemo()
            
        case .Environment:
            configureEnvironmentDemo()

        case .Motion:
            configureMotionDemo()
        }
    }
    
    func resetDemoConfiguration() {
        log.debug("Demo Reset Requested")
        delay(1) {
            self.configurationDelegate?.demoConfigurationReset()
        }
    }
    
    private func deviceIdentifierUpdated() {
        guard let deviceIdentifier = deviceIdentifier else { return }
        self.configurationDelegate?.deviceIdentifierUpdated(deviceIdentifier)
    }
    
    private func configureIoDemo() {
        self.configurationDelegate?.configuringIoDemo()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            let connection = SimulatedIoDemoConnection(device: self)
            self.configurationDelegate?.ioDemoReady(connection)
            self.demoConnection = connection
        }
    }
    
    private func configureEnvironmentDemo() {
        self.configurationDelegate?.configuringEnvironmentDemo()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            let connection = SimulatedEnvironmentDemoConnection(device: self)
            self.configurationDelegate?.environmentDemoReady(connection)
            self.demoConnection = connection
        }
    }
    
    private func configureMotionDemo() {
        self.configurationDelegate?.configuringMotionDemo()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            let connection = SimulatedMotionDemoConnection(device: self)
            self.configurationDelegate?.motionDemoReady(connection)
            self.demoConnection = connection
        }
    }
}