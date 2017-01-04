//
//  NotificationManager.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import CoreLocation

protocol NotificationManagerDelegate : class {
    func notificationsEnabled(_ enabled: Bool)
    func locationServicesNotAllowed()
}

protocol NotificationPresenter : class {
    func showDetectedDevice(_ device: NotificationDevice)
}

protocol NotificationManager : class {
    
    var notificationsEnabled: Bool { get set }
    weak var delegate: NotificationManagerDelegate? { get set }
    weak var presenter: NotificationPresenter? { get set }

    func enableNotifications(_ enable: Bool)
    func allowDevice(_ device: NotificationDevice)
    func removeDevice(_ device: NotificationDevice)
    func removeAllDevices()
    
    func allowedDevices() -> [NotificationDevice]
    func otherDevices() -> [NotificationDevice]
    
    func setConnectedDevices(_ devices: [Device])
}
