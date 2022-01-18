//
//  ApplicationPresenter.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
import SafariServices

typealias PresentationRoles = DeviceSelectionPresenter & DemoSelectionPresenter & DemoPresenter & NotificationPresenter & DemoHistoryPresenter & SettingsPresenter
class ApplicationPresenter : NSObject, DeviceTransportApplicationDelegate, ConnectedDeviceDelegate, PresentationRoles {

    var navigationController: NavigationController?
    var notificationManager: NotificationManager!

    fileprivate var factory = ViewControllerFactory()
    fileprivate var deviceViewController: DeviceSelectionViewController?
    fileprivate var deviceScanner: DeviceScanner!
    fileprivate var deviceConnector: DeviceConnection!
    fileprivate var deviceSelectionInteraction: DeviceSelectionInteraction?
    fileprivate var deviceId: DeviceId?

    init(window: UIWindow?) {

        super.init()
        
        factory.presenter = self
        
        #if targetEnvironment(simulator)
            let sim = SimulatedDeviceScanner()
            sim.applicationDelegate = self
            
            deviceScanner = sim
            deviceConnector = sim

            notificationManager = SimulatedNotificationManager()
        #else
            let ble = BleManager()
            ble.applicationDelegate = self
            
            deviceScanner = ble
            deviceConnector = ble
            
            notificationManager = BeaconNotificationManager()
            notificationManager?.presenter = self
        #endif
        
        let deviceViewController = factory.deviceSelectionViewController(deviceScanner, connector: deviceConnector, settingsPresenter: self)
        deviceViewController.presenter = self
        
        self.deviceSelectionInteraction = deviceViewController.interaction
        self.navigationController = NavigationController(rootViewController: deviceViewController)
        self.deviceViewController = deviceViewController
        
        self.navigationController?.addBottomNotchToHeight(window?.safeAreaInsets.bottom ?? 0.0)
        
        window?.rootViewController = self.navigationController
    }
    
    func connectToNearbyDevice(_ identifier: String) {
        deviceSelectionInteraction?.automaticallyConnectToDevice(identifier)
    }
    
    //MARK: - BleApplicationDelegate
    
    func transportPowerStateUpdated(_ state: DeviceTransportState) {
        deviceSelectionInteraction?.transportPowerStateUpdated(state)
    }
    
    func transportConnectedToDevice(_ device: Device) {
        device.connectedDelegate = self
        self.navigationController?.updateConnectedDevice(device.name ?? String.tb_placeholderText(), power: device.power, firmwareVersion: device.firmwareVersion)
        self.navigationController?.showConnectedDevice()
        notificationManager?.setConnectedDevices([device])
    }
    
    func transportDisconnectedFromDevice(_ device: Device) {
        self.deviceId = nil
        device.connectedDelegate = nil
        self.navigationController?.hideConnectedDevice()
        notificationManager?.setConnectedDevices([])
    }
    
    func transportLostConnectionToDevice(_ device: Device) {
        if let deviceName = device.name {
            self.navigationController?.showLostConnectionAlert(deviceName)
        }
    }
    
    //MARK:- ConnectedDeviceDelegate
    
    func connectedDeviceUpdated(_ name: String, RSSI: Int?, power: PowerSource, identifier: DeviceId?, firmwareVersion: String?) {
        self.navigationController?.updateConnectedDevice(name, power: power, firmwareVersion: firmwareVersion)
        self.deviceId = identifier
        self.navigationController?.showConnectedDevice()
    }
    
    //MARK: - DeviceSelectionPresenter
    
    func showDeviceSelection() {
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - DemoSelectionPresenter
    
    func showDemoSelection(_ configuration: DemoConfiguration) {
        let historyPresenter = self
        let demoView = factory.demoSelectionViewController(configuration, demoPresenter: self, settingsPresenter: self, historyPresenter: historyPresenter, notificationManager: notificationManager)
        
        self.navigationController?.pushViewController(demoView, animated: true)
    }
    
    //MARK: - DemoPresenter
    
    func showEnvironmentDemo(_ connection: EnvironmentDemoConnection) {
        let demo = factory.environmentDemoViewController(connection, settingsPresenter: self)
        self.navigationController?.pushViewController(demo, animated: true)
    }
    
    func showIoDemo(_ connection: IoDemoConnection) {
        let demo = factory.ioDemoViewController(connection, settingsPresenter: self)
        self.navigationController?.pushViewController(demo, animated: true)
    }

    func showMotionDemo(_ connection: MotionDemoConnection) {
        
        var demo: MotionDemoViewController!
        let settings = ThunderboardSettings()
        
        switch connection.device.model {
        case .react: fallthrough
        case .unknown:
            switch settings.motionDemoModel {
            case .board:
                demo = factory.motionBoardDemoViewController(connection, settingsPresenter: self)
            case .car:
                demo = factory.motionBoardDemoViewController(connection, settingsPresenter: self)
            }
        case .sense:
            if connection.device.modelName == "BRD4184A" || connection.device.modelName == "BRD4166B" {
                demo = factory.motionSense84BoardDemoViewController(connection, settingsPresenter: self)
            } else {
                demo = factory.motionSenseBoardDemoViewController(connection, settingsPresenter: self)
            }
        }
        
        self.navigationController?.pushViewController(demo, animated: true)
    }

    //MARK: - NotificationPresenter
    
    func showDetectedDevice(_ device: NotificationDevice) {
            
        let note = UILocalNotification()
        
        note.alertBody = "\(device.name) is ready. Would you like to connect to this Bluetooth device and start a demo?"
        note.alertAction = "Connect"
        note.userInfo = [
            "deviceName" : device.name,
            "deviceIdentifier" : device.identifier.toString()
        ]
        
        UIApplication.shared.presentLocalNotificationNow(note)
    }
    
    //MARK: - DemoStreamSharePresenter
    
    func shareDemoUrl(_ url: String) {
        log.debug("share url: \(url)")
        let provider = SharingActivityProvider(url: url)
        
        let safari = SafariActivity()
        let activity = UIActivityViewController(activityItems: [provider], applicationActivities: [safari])
        self.navigationController?.present(activity, animated: true, completion: nil)
    }
    
    //MARK: - DemoHistoryPresenter
    
    func showHistory() {
        guard let device = self.deviceId else {
            log.error("invalid device id for history presentation")
            return
        }
        
        let url = URL.tb_urlForDemoHistory(device)
        UIApplication.shared.open(url, options: [:]) { (success) in
            
        }
    }
    
    //MARK: - SettingsPresenter
    
    func showSettings() {
        let settings = factory.settingsViewController(notificationManager)
        self.navigationController?.present(settings, animated: true, completion: nil)
    }
}
