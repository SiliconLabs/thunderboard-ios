//
//  BeaconNotificationManager.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconNotificationManager : NSObject, NotificationManager, CLLocationManagerDelegate {

    weak var delegate: NotificationManagerDelegate?
    weak var presenter: NotificationPresenter?
    
    var notificationsEnabled: Bool {
        get { return settings.beaconNotifications }
        set (newValue) { enableNotifications(newValue) }
    }
    
    private let settings = ThunderboardSettings()
    private var clManager: CLLocationManager?
    private var connectedDevices: [Device]?
    
    override init() {
        super.init()
        enableNotifications(settings.beaconNotifications)
    }
    
    //MARK: - NotificationManager
    
    func enableNotifications(enable: Bool) {
        
        if enable {
            clManager = CLLocationManager()
            clManager?.delegate = self
            clManager?.desiredAccuracy = kCLLocationAccuracyBest
            
            requestLocationServicesAccess()
        }
            
        else {
            
            // stop monitoring regions
            if let regions = clManager?.monitoredRegions {
                for region in regions {
                    clManager?.stopMonitoringForRegion(region)
                }
            }
            
            clManager?.delegate = nil
            clManager = nil
            
            notificationsDisabled()
        }

        dumpDebugInformation()
    }
    
    func allowDevice(device: NotificationDevice) {
        let beacon = regionForDevice(device)
        clManager?.startMonitoringForRegion(beacon)
        dumpDebugInformation()
    }
    
    func removeDevice(device: NotificationDevice) {
        let region = regionForDevice(device)
        clManager?.stopMonitoringForRegion(region)
        
        removePreviousDevice(device)
        
        dumpDebugInformation()
    }
    
    func removeAllDevices() {
        // remove monitored regions
        let regions = regionMonitoredDevices()
        for region in regions {
            self.removeDevice(region)
        }
        
        // remove known devices
        let settings = ThunderboardSettings()
        settings.clearConnectedDeviceIds()
        
        dumpDebugInformation()
    }
    
    func allowedDevices() -> [NotificationDevice] {
        let devices = allDevices()
        let allowed = devices.allowed
        
        guard let connectedDevices = connectedDevices else {
            return allowed
        }

        // overlay connected devices with the allowed list
        return allowed.map({
            let device = $0
            let matching = connectedDevices.filter({ (connectedDevice: Device) -> Bool in
                return device.identifier == connectedDevice.deviceIdentifier
            })
            
            if matching.count > 0 {
                device.status = .Connected
            }
            
            return device
        })

    }
    
    func otherDevices() -> [NotificationDevice] {
        let devices = allDevices()
        return devices.other
    }
    
    func setConnectedDevices(devices: [Device]) {
        connectedDevices = devices
    }

    //MARK: - Private

    private func requestLocationServicesAccess() {
        clManager?.requestAlwaysAuthorization()
    }
    
    private func locationServicesAllowed() {
        settings.beaconNotifications = true
        self.delegate?.notificationsEnabled(true)
    }
    
    private func locationServicesDenied() {
        settings.beaconNotifications = false
        self.delegate?.locationServicesNotAllowed()
    }
    
    private func notificationsDisabled() {
        settings.beaconNotifications = false
        self.delegate?.notificationsEnabled(false)
    }
    
    private func allDevices() -> (allowed: [NotificationDevice], other: [NotificationDevice]) {
        
        // Find all devices in the "connected history"
        let pastDevices = previouslyConnectedDevices()
        
        // Find regions being monitored ("allowed" devices)
        let beaconDevices = regionMonitoredDevices()

        // remove beacons from pastDevices
        let otherDevices = pastDevices.filter({ beaconDevices.contains($0) ? false : true })
        
        return (allowed: beaconDevices, other: otherDevices)
    }
    
    private func deviceWithId(deviceId: DeviceId) -> NotificationDevice? {
        let devices = previouslyConnectedDevices()
        return devices.filter({ $0.identifier == deviceId }).first
    }
    
    private func previouslyConnectedDevices() -> [NotificationDevice] {
        return settings.connectedDevices
    }
    
    private func removePreviousDevice(device: NotificationDevice) {
        settings.removeConnectedDevice(device)
    }
    
    private func regionMonitoredDevices() -> [NotificationDevice] {
        guard let regions = clManager?.monitoredRegions else {
            return []
        }

        let beacons = regions.filter({
            if let _ = $0 as? CLBeaconRegion {
                return true
            }
            return false
        }) as! [CLBeaconRegion]

        let previous = previouslyConnectedDevices()
        return beacons.map({ beacon -> NotificationDevice in
            let identifier = deviceIdentifierForRegion(beacon)

            return previous.filter({ $0.identifier == identifier }).first!
        })
    }
    
    private func deviceIdentifierForRegion(region: CLBeaconRegion) -> DeviceId {
        guard let major = region.major?.longLongValue, minor = region.minor?.longLongValue else {
            return 0
        }

        return DeviceId((major << 16) + minor)
    }
    
    private func regionForDevice(device: NotificationDevice) -> CLBeaconRegion {
        let deviceId = device.identifier
        let major = CLBeaconMajorValue( (deviceId >> 16) & 0xFFFF )
        let minor = CLBeaconMinorValue( deviceId & 0xFFFF )
        let identifier = "\(device.identifier)"
        let beacon = CLBeaconRegion(proximityUUID: ThunderboardBeaconId, major: major, minor: minor, identifier: identifier)
        beacon.notifyEntryStateOnDisplay = true
        beacon.notifyOnEntry = true
        beacon.notifyOnExit = true
        
        return beacon
    }
    
    private func requestStateForMonitoredRegions() {
        guard let regions = clManager?.monitoredRegions else {
            return
        }
        
        for region in regions {
            if let beacon = region as? CLBeaconRegion {
                clManager?.requestStateForRegion(beacon)
            }
        }
    }
    
    private func dumpDebugInformation() {
        let regions = clManager?.monitoredRegions
        log.debug("monitored regions: \(regions)")
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        log.info("Authorization status changed: \(status.rawValue)")
        
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            locationServicesAllowed()
            
        case .Denied, .Restricted:
            locationServicesDenied()
            
        case .NotDetermined:
            // NO-OP: decision from the user forthcoming
            break
        }
    }

    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        log.debug("\(region)")
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        log.error("\(region) error \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // entered region
        log.info("\(region)")
        guard let beacon = region as? CLBeaconRegion else {
            log.error("Entered region was not a valid beacon region")
            return
        }
        
        // only send notification if we're in the background
        let application = UIApplication.sharedApplication()
        if application.applicationState != .Active {
            let deviceId = deviceIdentifierForRegion(beacon)
            if let device = deviceWithId(deviceId) {
                log.info("detected device id \(deviceId)")
                self.presenter?.showDetectedDevice(device)
            }
            else {
                log.error("** failed to find device for id \(deviceId), cannot display alert **")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        // exited region
        log.info("\(region)")
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        // determined state
        switch state {
        case .Inside:
            log.info("didDetermineState: .Inside")
        case .Outside:
            log.info("didDetermineState: .Outside")
        case .Unknown:
            log.info("didDetermineState: .Unknown")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        log.error("\(error)")
    }
    
}
