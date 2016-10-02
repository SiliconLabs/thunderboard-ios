//
//  SimulatedDevice.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class SimulatedDevice : Device, DemoConfiguration, Equatable, CustomDebugStringConvertible {
    
    private (set) var model: DeviceModel
    var name: String?
    var deviceIdentifier: DeviceId? {
        didSet {
            self.deviceIdentifierUpdated()
        }
    }
    var RSSI: Int?
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
                    self.power = [
                        .USB,
                        .AA(99),
                        .AA(70),
                        .CoinCell(27),
                        .CoinCell(13),
                        .CoinCell(5),
                    ].random()
                    self.firmwareVersion = "1.0.0";
                    self.notifyConnectedDelegate()
                }
            }
        }
    }
    
    private (set) var power: PowerSource = .Unknown
    private (set) var capabilities: Set<DeviceCapability> = []
    
    weak var connectedDelegate: ConnectedDeviceDelegate?
    weak var simulatedScanner: SimulatedDeviceScanner?
    weak var demoConnection: DemoConnection?
    
    init(name: String, identifier: DeviceId, capabilities: Set<DeviceCapability>, rssi: Int? = nil, model: DeviceModel? = .React) {
        self.model = model ?? .React
        self.name = name
        self.deviceIdentifier = identifier
        self.capabilities = capabilities
        self.RSSI = rssi ?? -40

        connectionState = .Disconnected
        
        delay(2.0) {
            self.deviceIdentifier = DeviceId(100)
            self.notifyConnectedDelegate()
        }
    }
    
    private func notifyConnectedDelegate() {
        self.connectedDelegate?.connectedDeviceUpdated(self.name!, RSSI: self.RSSI, power: self.power, identifier: self.deviceIdentifier, firmwareVersion: self.firmwareVersion)
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
        get { return "\(name): \(deviceIdentifier) \(capabilities) \(power)" }
    }
    
    //MARK: - Private
    
    private func simulateLostConnection() {

        self.simulatedScanner?.simulateLostConnection(self)
    }
    
    //MARK: - DemoConfiguration
    
    weak var configurationDelegate: DemoConfigurationDelegate?
    func configureForDemo(demo: ThunderboardDemo) {

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
        delay(0.2) {
            let connection = SimulatedIoDemoConnection(device: self)
            self.configurationDelegate?.ioDemoReady(connection)
            self.demoConnection = connection
        }
    }
    
    private func configureEnvironmentDemo() {
        self.configurationDelegate?.configuringEnvironmentDemo()
        
        delay(0.5) {
            let connection = SimulatedEnvironmentDemoConnection(device: self)
            self.configurationDelegate?.environmentDemoReady(connection)
            self.demoConnection = connection
        }
    }
    
    private func configureMotionDemo() {
        self.configurationDelegate?.configuringMotionDemo()
        
        delay(0.5) {
            let connection = SimulatedMotionDemoConnection(device: self)
            self.configurationDelegate?.motionDemoReady(connection)
            self.demoConnection = connection
        }
    }
}

func ==(lhs: SimulatedDevice, rhs: SimulatedDevice) -> Bool {
    return lhs.deviceIdentifier == rhs.deviceIdentifier
}

extension Array {
    func random() -> Element {
        let randomIndex = Int(rand()) % count
        return self[randomIndex]
    }
}