//
//  ThunderboardSettings.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ThunderboardSettings: NSObject {

    fileprivate let defaults = UserDefaults.standard

    override init() {
        super.init()
        registerDefaults()
    }
    
    //MARK: Measurement Units
    fileprivate let measurementKey = "measurementUnits"
    var measurement: MeasurementUnits {
        get {
            return MeasurementUnits(rawValue: defaults.integer(forKey: measurementKey))!
        }
        set (newValue) {
            defaults.set(newValue.rawValue, forKey: measurementKey)
        }
    }
    
    //MARK: Temperature Units
    fileprivate let temperatureKey = "temperatureUnits"
    var temperature: TemperatureUnits {
        get {
            return TemperatureUnits(rawValue: defaults.integer(forKey: temperatureKey))!
        }
        set (newValue) {
            defaults.set(newValue.rawValue, forKey: temperatureKey)
        }
    }
    
    //MARK: Motion Demo
    fileprivate let motionDemoModelKey = "motionDemoModel"
    var motionDemoModel: MotionDemoModel {
        get {
            return MotionDemoModel(rawValue: defaults.integer(forKey: motionDemoModelKey))!
        }
        set (newValue) {
            defaults.set(newValue.rawValue, forKey: motionDemoModelKey)
        }
    }
    
    //MARK: User Name
    fileprivate let userNameKey = "userName"
    var userName: String? {
        get {
            return identityOrNilForEmpty(defaults.string(forKey: userNameKey))
        }
        set (newValue) {
            defaults.setValue(newValue, forKey: userNameKey)
        }
    }
    
    fileprivate let userTitleKey = "userTitle"
    var userTitle: String? {
        get {
            return identityOrNilForEmpty(defaults.string(forKey: userTitleKey))
        }
        set (newValue) {
            defaults.setValue(newValue, forKey: userTitleKey)
        }
    }
    
    fileprivate let userPhoneKey = "userPhone"
    var userPhone: String? {
        get {
            return identityOrNilForEmpty(defaults.string(forKey: userPhoneKey))
        }
        set (newValue) {
            defaults.setValue(newValue, forKey: userPhoneKey)
        }
    }
    
    fileprivate let userEmailKey = "userEmail"
    var userEmail: String? {
        get {
            return identityOrNilForEmpty(defaults.string(forKey: userEmailKey))
        }
        set (newValue) {
            defaults.setValue(newValue, forKey: userEmailKey)
        }
    }
    
    fileprivate let notificationsKey = "beaconNotifications"
    var beaconNotifications: Bool {
        get {
            return defaults.bool(forKey: notificationsKey)
        }
        set (newValue) {
            defaults.set(newValue, forKey: notificationsKey)
        }
    }
    
    fileprivate let connectedDevicesHistoryKey = "connectedDevices"
    var connectedDevices: [NotificationDevice] {
        get {
            guard let data = defaults.object(forKey: connectedDevicesHistoryKey) as? Data else {
                return []
            }
            
            guard let devices = NSKeyedUnarchiver.unarchiveObject(with: data) as? [NotificationDevice] else {
                return []
            }

            return devices
        }
        
        set (newList) {
            let data = NSKeyedArchiver.archivedData(withRootObject: newList)
            defaults.set(data, forKey: connectedDevicesHistoryKey)
        }
    }
    
    func addConnectedDevice(_ device: NotificationDevice) {
        var devices = connectedDevices
        if devices.contains(device) == false {
            devices.append(device)
            connectedDevices = devices
        }
    }
    
    func removeConnectedDevice(_ device: NotificationDevice) {
        var devices = connectedDevices
        if let index = devices.index(of: device) {
            devices.remove(at: index)
            connectedDevices = devices
        }
    }
    
    func clearConnectedDeviceIds() {
        defaults.removeObject(forKey: connectedDevicesHistoryKey)
    }
    
    
    //MARK: - Internal
    fileprivate func registerDefaults() {
        
        let defaultValues = [
            self.measurementKey     : MeasurementUnits.imperial.rawValue,
            self.temperatureKey     : TemperatureUnits.fahrenheit.rawValue,
            self.userNameKey        : "",
            self.userTitleKey       : "",
            self.userPhoneKey       : "",
            self.userEmailKey       : "",
            self.motionDemoModelKey : MotionDemoModel.board.rawValue,
        ] as [String : Any]
        
        self.defaults.register(defaults: defaultValues as [String : AnyObject])
    }
    
    fileprivate func identityOrNilForEmpty(_ value: String?) -> String? {
        if value?.characters.count > 1 {
            return value
        }
        
        return nil
    }
}
