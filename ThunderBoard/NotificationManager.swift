//
//  NotificationManager.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import CoreLocation

protocol NotificationManagerDelegate : class {
    func notificationsEnabled(enabled: Bool)
    func locationServicesNotAllowed()
}

protocol NotificationPresenter : class {
    func showDetectedDevice(device: NotificationDevice)
}

protocol NotificationManager : class {
    
    var notificationsEnabled: Bool { get set }
    weak var delegate: NotificationManagerDelegate? { get set }
    weak var presenter: NotificationPresenter? { get set }

    func enableNotifications(enable: Bool)
    func allowDevice(device: NotificationDevice)
    func removeDevice(device: NotificationDevice)
    func removeAllDevices()
    
    func allowedDevices() -> [NotificationDevice]
    func otherDevices() -> [NotificationDevice]
    
    func setConnectedDevices(devices: [Device])
}
