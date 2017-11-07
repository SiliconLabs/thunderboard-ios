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
    
    fileprivate let settings = ThunderboardSettings()
    fileprivate var clManager: CLLocationManager?
    fileprivate var connectedDevices: [Device]?
    
    override init() {
        super.init()
        enableNotifications(settings.beaconNotifications)
    }
    
    //MARK: - NotificationManager
    
    func enableNotifications(_ enable: Bool) {
        
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
                    clManager?.stopMonitoring(for: region)
                }
            }
            
            clManager?.delegate = nil
            clManager = nil
            
            notificationsDisabled()
        }

        dumpDebugInformation()
    }
    
    func allowDevice(_ device: NotificationDevice) {
        let beacon = regionForDevice(device)
        clManager?.startMonitoring(for: beacon)
        dumpDebugInformation()
    }
    
    func removeDevice(_ device: NotificationDevice) {
        let region = regionForDevice(device)
        clManager?.stopMonitoring(for: region)
        
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
    
    func setConnectedDevices(_ devices: [Device]) {
        connectedDevices = devices
    }

    //MARK: - Private

    fileprivate func requestLocationServicesAccess() {
        clManager?.requestAlwaysAuthorization()
    }
    
    fileprivate func locationServicesAllowed() {
        settings.beaconNotifications = true
        self.delegate?.notificationsEnabled(true)
    }
    
    fileprivate func locationServicesDenied() {
        settings.beaconNotifications = false
        self.delegate?.locationServicesNotAllowed()
    }
    
    fileprivate func notificationsDisabled() {
        settings.beaconNotifications = false
        self.delegate?.notificationsEnabled(false)
    }
    
    fileprivate func allDevices() -> (allowed: [NotificationDevice], other: [NotificationDevice]) {
        
        // Find all devices in the "connected history"
        let pastDevices = previouslyConnectedDevices()
        
        // Find regions being monitored ("allowed" devices)
        let beaconDevices = regionMonitoredDevices()

        // remove beacons from pastDevices
        let otherDevices = pastDevices.filter({ beaconDevices.contains($0) ? false : true })
        
        return (allowed: beaconDevices, other: otherDevices)
    }
    
    fileprivate func deviceWithId(_ deviceId: DeviceId) -> NotificationDevice? {
        let devices = previouslyConnectedDevices()
        return devices.filter({ $0.identifier == deviceId }).first
    }
    
    fileprivate func previouslyConnectedDevices() -> [NotificationDevice] {
        return settings.connectedDevices
    }
    
    fileprivate func removePreviousDevice(_ device: NotificationDevice) {
        settings.removeConnectedDevice(device)
    }
    
    fileprivate func regionMonitoredDevices() -> [NotificationDevice] {
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
    
    fileprivate func deviceIdentifierForRegion(_ region: CLBeaconRegion) -> DeviceId {
        guard let major = region.major?.int64Value, let minor = region.minor?.int64Value else {
            return 0
        }

        return DeviceId((major << 16) + minor)
    }
    
    fileprivate func regionForDevice(_ device: NotificationDevice) -> CLBeaconRegion {
        let deviceId = device.identifier
        let major = CLBeaconMajorValue( (deviceId >> 16) & 0xFFFF )
        let minor = CLBeaconMinorValue( deviceId & 0xFFFF )
        let identifier = "\(device.identifier)"
        let beacon = CLBeaconRegion(proximityUUID: ThunderboardBeaconId as UUID, major: major, minor: minor, identifier: identifier)
        beacon.notifyEntryStateOnDisplay = true
        beacon.notifyOnEntry = true
        beacon.notifyOnExit = true
        
        return beacon
    }
    
    fileprivate func requestStateForMonitoredRegions() {
        guard let regions = clManager?.monitoredRegions else {
            return
        }
        
        for region in regions {
            if let beacon = region as? CLBeaconRegion {
                clManager?.requestState(for: beacon)
            }
        }
    }
    
    fileprivate func dumpDebugInformation() {
        let regions = clManager?.monitoredRegions
        log.debug("monitored regions: \(regions)")
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        log.info("Authorization status changed: \(status.rawValue)")
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationServicesAllowed()
            
        case .denied, .restricted:
            locationServicesDenied()
            
        case .notDetermined:
            // NO-OP: decision from the user forthcoming
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        log.debug("\(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        log.error("\(region) error \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // entered region
        log.info("\(region)")
        guard let beacon = region as? CLBeaconRegion else {
            log.error("Entered region was not a valid beacon region")
            return
        }
        
        // only send notification if we're in the background
        let application = UIApplication.shared
        if application.applicationState != .active {
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
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // exited region
        log.info("\(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        // determined state
        switch state {
        case .inside:
            log.info("didDetermineState: .Inside")
        case .outside:
            log.info("didDetermineState: .Outside")
        case .unknown:
            log.info("didDetermineState: .Unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.error("\(error)")
    }
    
}
