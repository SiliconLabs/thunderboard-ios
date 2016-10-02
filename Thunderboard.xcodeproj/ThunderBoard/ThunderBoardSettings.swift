//
//  ThunderboardSettings.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class ThunderboardSettings: NSObject {

    private let defaults = NSUserDefaults.standardUserDefaults()

    override init() {
        super.init()
        registerDefaults()
    }
    
    //MARK: Measurement Units
    private let measurementKey = "measurementUnits"
    var measurement: MeasurementUnits {
        get {
            return MeasurementUnits(rawValue: defaults.integerForKey(measurementKey))!
        }
        set (newValue) {
            defaults.setInteger(newValue.rawValue, forKey: measurementKey)
        }
    }
    
    //MARK: Temperature Units
    private let temperatureKey = "temperatureUnits"
    var temperature: TemperatureUnits {
        get {
            return TemperatureUnits(rawValue: defaults.integerForKey(temperatureKey))!
        }
        set (newValue) {
            defaults.setInteger(newValue.rawValue, forKey: temperatureKey)
        }
    }
    
    //MARK: Motion Demo
    private let motionDemoModelKey = "motionDemoModel"
    var motionDemoModel: MotionDemoModel {
        get {
            return MotionDemoModel(rawValue: defaults.integerForKey(motionDemoModelKey))!
        }
        set (newValue) {
            defaults.setInteger(newValue.rawValue, forKey: motionDemoModelKey)
        }
    }
    
    //MARK: User Name
    private let userNameKey = "userName"
    var userName: String? {
        get {
            return identityOrNilForEmpty(defaults.stringForKey(userNameKey))
        }
        set (newValue) {
            defaults.setValue(newValue, forKey: userNameKey)
        }
    }
    
    private let userTitleKey = "userTitle"
    var userTitle: String? {
        get {
            return identityOrNilForEmpty(defaults.stringForKey(userTitleKey))
        }
        set (newValue) {
            defaults.setValue(newValue, forKey: userTitleKey)
        }
    }
    
    private let userPhoneKey = "userPhone"
    var userPhone: String? {
        get {
            return identityOrNilForEmpty(defaults.stringForKey(userPhoneKey))
        }
        set (newValue) {
            defaults.setValue(newValue, forKey: userPhoneKey)
        }
    }
    
    private let userEmailKey = "userEmail"
    var userEmail: String? {
        get {
            return identityOrNilForEmpty(defaults.stringForKey(userEmailKey))
        }
        set (newValue) {
            defaults.setValue(newValue, forKey: userEmailKey)
        }
    }
    
    private let notificationsKey = "beaconNotifications"
    var beaconNotifications: Bool {
        get {
            return defaults.boolForKey(notificationsKey)
        }
        set (newValue) {
            defaults.setBool(newValue, forKey: notificationsKey)
        }
    }
    
    private let connectedDevicesHistoryKey = "connectedDevices"
    var connectedDevices: [NotificationDevice] {
        get {
            guard let data = defaults.objectForKey(connectedDevicesHistoryKey) as? NSData else {
                return []
            }
            
            guard let devices = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NotificationDevice] else {
                return []
            }

            return devices
        }
        
        set (newList) {
            let data = NSKeyedArchiver.archivedDataWithRootObject(newList)
            defaults.setObject(data, forKey: connectedDevicesHistoryKey)
        }
    }
    
    func addConnectedDevice(device: NotificationDevice) {
        var devices = connectedDevices
        if devices.contains(device) == false {
            devices.append(device)
            connectedDevices = devices
        }
    }
    
    func removeConnectedDevice(device: NotificationDevice) {
        var devices = connectedDevices
        if let index = devices.indexOf(device) {
            devices.removeAtIndex(index)
            connectedDevices = devices
        }
    }
    
    func clearConnectedDeviceIds() {
        defaults.removeObjectForKey(connectedDevicesHistoryKey)
    }
    
    
    //MARK: - Internal
    private func registerDefaults() {
        
        let defaultValues = [
            self.measurementKey     : MeasurementUnits.Imperial.rawValue,
            self.temperatureKey     : TemperatureUnits.Fahrenheit.rawValue,
            self.userNameKey        : "",
            self.userTitleKey       : "",
            self.userPhoneKey       : "",
            self.userEmailKey       : "",
            self.motionDemoModelKey : MotionDemoModel.Board.rawValue,
        ]
        
        self.defaults.registerDefaults(defaultValues as! [String : AnyObject])
    }
    
    private func identityOrNilForEmpty(value: String?) -> String? {
        if value?.characters.count > 1 {
            return value
        }
        
        return nil
    }
}
