//
//  NotificationSettingsInteraction.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

let UserNotificationSettingsUpdatedEvent = "com.silabs.notificationsettings"

protocol NotificationSettingsInteractionOutput : class {
    func notificationsEnabled(enabled: Bool)
    func notificationDevicesUpdated()

    func locationServicesNotAllowed()
    func notificationsNotAllowed()
}

class NotificationSettingsInteraction : NotificationManagerDelegate {
    
    weak var manager: NotificationManager? {
        didSet {
            manager?.delegate = self
            notifyUpdates()
        }
    }
    
    weak var output: NotificationSettingsInteractionOutput? {
        didSet {
            notifyUpdates()
        }
    }

    init() {
        NSNotificationCenter.defaultCenter().addObserverForName(UserNotificationSettingsUpdatedEvent, object: nil, queue: nil) { [weak self] (notification: NSNotification) -> Void in
            self?.notificationSettingsUpdated()
        }
    }
    
    func enableNotifications(enabled: Bool) {
        // During testing, this may be a desired behavior
        // if enabled == false {
        //     removeAllDevices()
        // }

        self.manager?.enableNotifications(enabled)
    }
    
    func allowDevice(index: Int) {
        self.manager?.allowDevice(otherDevices()[index])
        notifyUpdates()
    }
    
    func removeDevice(index: Int) {
        self.manager?.removeDevice(allowedDevices()[index])
        notifyUpdates()
    }
    
    func allowedDevices() -> [NotificationDevice] {
        guard let devices = self.manager?.allowedDevices() else {
            return []
        }
        
        return devices.map({
            return self.displayDevice($0)
        })
    }
    
    func otherDevices() -> [NotificationDevice] {
        guard let devices = self.manager?.otherDevices() else {
            return []
        }
        
        return devices.map({
            return self.displayDevice($0)
        })
    }
   
    //MARK: - NotificationManagerDelegate
    
    func notificationsEnabled(enabled: Bool) {
        notifyUpdates()
        
        if enabled {
            let settings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
    }
    
    func locationServicesNotAllowed() {
        self.manager?.enableNotifications(false)
        output?.locationServicesNotAllowed()
    }
    
    func notificationsNotAllowed() {
        self.manager?.enableNotifications(false)
        output?.notificationsNotAllowed()
    }
    
    //MARK: - Private
    
    private func notificationSettingsUpdated() {
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        if settings?.types.contains(.Alert) == false {
            notificationsNotAllowed()
        }
    }
    
    private func notifyUpdates() {
        if let enabled = self.manager?.notificationsEnabled {
            output?.notificationsEnabled(enabled)
            output?.notificationDevicesUpdated()
        }
    }
    
    private func removeAllDevices() {
        self.manager?.removeAllDevices()
    }
    
    private func displayDevice(notificationDevice: NotificationDevice) -> NotificationDevice {
        return notificationDevice
    }
}
