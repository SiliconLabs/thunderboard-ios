//
//  ApplicationPresenter.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
import SafariServices

typealias PresentationRoles = protocol<DeviceSelectionPresenter, DemoSelectionPresenter, DemoPresenter, DemoStreamSharePresenter, NotificationPresenter, DemoHistoryPresenter, SettingsPresenter>
class ApplicationPresenter : NSObject, DeviceTransportApplicationDelegate, ConnectedDeviceDelegate, PresentationRoles {

    var navigationController: NavigationController?
    var notificationManager: NotificationManager!

    private var factory = ViewControllerFactory()
    private var deviceViewController: DeviceSelectionViewController?
    private var deviceScanner: DeviceScanner!
    private var deviceConnector: DeviceConnection!
    private var deviceSelectionInteraction: DeviceSelectionInteraction?
    private var deviceId: DeviceId?

    init(window: UIWindow?) {

        super.init()
        
        factory.presenter = self
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
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
        
        window?.rootViewController = self.navigationController
    }
    
    func connectToNearbyDevice(identifier: String) {
        deviceSelectionInteraction?.automaticallyConnectToDevice(identifier)
    }
    
    //MARK: - BleApplicationDelegate
    
    func transportPowerStateUpdated(state: DeviceTransportState) {
        deviceSelectionInteraction?.transportPowerStateUpdated(state)
    }
    
    func transportConnectedToDevice(device: Device) {
        device.connectedDelegate = self
        self.navigationController?.updateConnectedDevice(device.name ?? String.tb_placeholderText(), power: device.power, firmwareVersion: device.firmwareVersion)
        self.navigationController?.showConnectedDevice()
        notificationManager?.setConnectedDevices([device])
    }
    
    func transportDisconnectedFromDevice(device: Device) {
        self.deviceId = nil
        device.connectedDelegate = nil
        self.navigationController?.hideConnectedDevice()
        notificationManager?.setConnectedDevices([])
    }
    
    func transportLostConnectionToDevice(device: Device) {
        if let deviceName = device.name {
            self.navigationController?.showLostConnectionAlert(deviceName)
        }
    }
    
    //MARK:- ConnectedDeviceDelegate
    
    func connectedDeviceUpdated(name: String, RSSI: Int?, power: PowerSource, identifier: DeviceId?, firmwareVersion: String?) {
        self.navigationController?.updateConnectedDevice(name, power: power, firmwareVersion: firmwareVersion)
        self.deviceId = identifier
        self.navigationController?.showConnectedDevice()
    }
    
    //MARK: - DeviceSelectionPresenter
    
    func showDeviceSelection() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    //MARK: - DemoSelectionPresenter
    
    func showDemoSelection(configuration: DemoConfiguration) {
        let historyPresenter = self
        let demoView = factory.demoSelectionViewController(configuration, demoPresenter: self, settingsPresenter: self, historyPresenter: historyPresenter, notificationManager: notificationManager)
        
        self.navigationController?.pushViewController(demoView, animated: true)
    }
    
    //MARK: - DemoPresenter
    
    func showEnvironmentDemo(connection: EnvironmentDemoConnection) {
        let demo = factory.environmentDemoViewController(connection)
        self.navigationController?.pushViewController(demo, animated: true)
    }
    
    func showIoDemo(connection: IoDemoConnection) {
        let demo = factory.ioDemoViewController(connection)
        self.navigationController?.pushViewController(demo, animated: true)
    }

    func showMotionDemo(connection: MotionDemoConnection) {
        
        var demo: MotionDemoViewController!
        let settings = ThunderboardSettings()
        
        switch connection.device.model {
        case .React: fallthrough
        case .Unknown:
            switch settings.motionDemoModel {
            case .Board:
                demo = factory.motionBoardDemoViewController(connection)
            case .Car:
                demo = factory.motionCarDemoViewController(connection)
            }
        case .Sense:
            demo = factory.motionSenseBoardDemoViewController(connection)
        }
        
        
        self.navigationController?.pushViewController(demo, animated: true)
    }

    
    //MARK: - NotificationPresenter
    
    func showDetectedDevice(device: NotificationDevice) {
            
        let note = UILocalNotification()
        
        note.alertBody = "\(device.name) is ready. Would you like to connect to this Bluetooth device and start a demo?"
        note.alertAction = "Connect"
        note.userInfo = [
            "deviceName" : device.name,
            "deviceIdentifier" : device.identifier.toString()
        ]
        
        UIApplication.sharedApplication().presentLocalNotificationNow(note)
    }
    
    //MARK: - DemoStreamSharePresenter
    
    func shareDemoUrl(url: String) {
        log.debug("share url: \(url)")
        let provider = SharingActivityProvider(url: url)
        
        let safari = SafariActivity()
        let activity = UIActivityViewController(activityItems: [provider], applicationActivities: [safari])
        self.navigationController?.presentViewController(activity, animated: true, completion: nil)
    }
    
    //MARK: - DemoHistoryPresenter
    
    func showHistory() {
        guard let device = self.deviceId else {
            log.error("invalid device id for history presentation")
            return
        }
        
        let url = NSURL.tb_urlForDemoHistory(device)
        UIApplication.sharedApplication().openURL(url)
    }
    
    //MARK: - SettingsPresenter
    
    func showSettings() {
        let settings = factory.settingsViewController(notificationManager)
        self.navigationController?.presentViewController(settings, animated: true, completion: nil)
    }
}
