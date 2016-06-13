//
//  DemoStreamingConnection.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import Firebase

struct DemoStreamingDataPoint {
    var path: String
    var timestamp: String
    var data: AnyObject
}

/// Base class implementation of streaming support. Each demo subclasses @c DemoStreamingConnection to inherit most functionality
class DemoStreamingConnection : DemoStreaming {
    
    /// The sharable URL (displays an HTML view into the live data)
    var demoURL: String?
    var urlShortener = IsgdShortener()
    private weak var output: DemoStreamingOutput?

    private var device: Device
    private var streamingEnabled: Bool = false
    private var firebase: Firebase?
    private var firebaseConnectionObserver: Firebase?
    private var firebaseConnected = false
    
    private let firebaseIoHost   = ApplicationConfig.FirebaseIoHost
    private let firebaseDemoHost = ApplicationConfig.FirebaseDemoHost
    private let firebaseToken    = ApplicationConfig.FirebaseToken
    private let shareUrlTemplate = "https://__FIREBASEDEMOHOST__/#/__DEVICEID_/__SESSIONID__/__DEMOTYPE__"

    init(device: Device, output: DemoStreamingOutput?) {
        
        self.device = device
        self.output = output
        
        defer {
            self.output?.streamingEnabled(streamingEnabled)
        }
        
        // if Firebase configuration is valid, enable the feature
        guard let url = NSURL(string: "https://\(firebaseIoHost)") else {
            log.error("Firebase IO Host invalid - streaming disabled")
            streamingEnabled = false
            return
        }
        
        guard let _ = NSURL(string: "https://\(firebaseDemoHost)") else {
            log.error("Firebase demo host invalid - streaming disabled")
            streamingEnabled = false
            return
        }
        
        if firebaseToken.characters.count != 40 {
            log.error("Firebase token invalid - streaming disabled")
            streamingEnabled = false
            return
        }
        
        log.debug("Firebase configuration valid - streaming enabled")
        streamingEnabled = true
        
        self.firebase = Firebase(url: url.absoluteString)
        
        self.firebaseConnectionObserver = Firebase(url: "https://\(firebaseIoHost)/.info/connected")
        firebaseConnectionObserver?.observeEventType(.Value, withBlock: { [weak self] snapshot in
            let connected = snapshot.value as? Bool
            if connected != nil && connected! {
                self?.firebaseConnected = true
            } else {
                self?.firebaseConnected = false
            }
        })
    }
    
    //MARK: - DemoStreaming Protocol
    
    func startStreaming() {
        
        log.info("starting stream for device \(device)")
        let type = demoType()
        let deviceId = device.deviceIdentifier!
        let (sessionId, fullDemoUrl) = createNewSession(deviceId, demoType: type)
        
        let queue = NSOperationQueue()
        queue.suspended = true
        
        let start = queue.tb_addAsyncOperationBlock("Notify Stream Starting") { [weak self] (operation: AsyncOperation) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self?.output?.streamStarting(fullDemoUrl)
                operation.done()
            })
        }

        var error: NSError? = nil
        let authentication = queue.tb_addAsyncOperationBlock("Firebase Authentication") { [weak self] (operation: AsyncOperation) -> Void in
            
            self?.firebase?.authWithCustomToken(self?.firebaseToken, withCompletionBlock: { (fbError: NSError!, authData: FAuthData!) -> Void in
                
                if fbError != nil {
                    log.error("Firebase authentication error: \(fbError)")
                    error = fbError
                }
                else {
                    log.info("Firebase authentication successful")
                }
                
                operation.done()
            })
        }

        let shortener = queue.tb_addAsyncOperationBlock("Shorten URL") { [weak self] (operation: AsyncOperation) -> Void in
            
            // set full url as fallback
            self?.demoURL = fullDemoUrl
            
            self?.urlShortener.shortenUrl(fullDemoUrl) { (shortDemoUrl, shortenError) -> Void in

                // NOTE: ignore shortening errors - user will be presented with full URL to avoid breaking demos
                if let url = shortDemoUrl {
                    log.info("Shortened demo URL: \(url)")
                    self?.demoURL = url
                }
                else {
                    
                    if let _ = shortenError {
                        log.error("Error shortening URL: \(shortenError)")
                        // error = shortenError

                    }
                        
                    else {
                        log.error("Missing Short URL, no error returned from API")
                        // error = ErrorFactory.shortenerUnknownError()
                    }
                }
                
                operation.done()
            }
        }

        let finished = queue.tb_addAsyncOperationBlock("Finished") { [weak self] (operation: AsyncOperation) -> Void in
            
            log.info("Finished operation starting...")
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                guard let strongSelf = self else {
                    return
                }
                
                if error == nil {
                    let url = strongSelf.demoURL as String!
                    strongSelf.beginStreamingSession(strongSelf.device, sessionId: sessionId, shortUrl: url)
                    strongSelf.startPollingTimers()
                    
                    strongSelf.output?.streamStarted(url)
                }
                else {
                    strongSelf.output?.streamFailedToStart(error!)
                }
                
                operation.done()
            })
        }
        
        // "Starting" notification
        shortener.addDependency(start)
        authentication.addDependency(start)
        
        // Wait for parallel tasks
        finished.addDependency(shortener)
        finished.addDependency(authentication)
        
        queue.suspended = false
    }
 
    func stopStreaming() {
        stopPollingTimers()
        
        endStreamingSession()
        
        // send remaining samples
        reportCurrentData()
        
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.output?.streamStopped()
        })
        
        demoURL = nil
    }
    
    func currentSession() -> (shortUrl: String, connected: Bool) {
        if let url = demoURL {
            return (url, firebaseConnected)
        }
        
        return ("", firebaseConnected)
    }
    
    func demoType() -> String {
        assert(false)
        return ""
    }
    
    func sampleFrequency() -> NSTimeInterval {
        return NSTimeInterval(1.0)
    }
    
    func reportingFrequency() -> NSTimeInterval {
        return NSTimeInterval(1.0)
    }
    
    //MARK:- Internal - Streaming Data
    
    private var currentDemoSession: Firebase?
    private func createNewSession(deviceId: DeviceId, demoType: String) -> (sessionId: String, shareUrl: String) {

        let sessionId = NSUUID().UUIDString
        let urlString = shareUrlTemplate.tb_stringByReplacingTokenPairs([
            "__FIREBASEDEMOHOST__" : firebaseDemoHost,
            "__DEVICEID_" : deviceId.toString(),
            "__SESSIONID__" : sessionId,
            "__DEMOTYPE__"  : demoType
        ])
        
        log.info("created session id \(sessionId) with url \(urlString)")
        return (sessionId, urlString)
    }
    
    private func beginStreamingSession(device: Device, sessionId: String, shortUrl: String) {
        
        guard let firebase = firebase, deviceId = device.deviceIdentifier, deviceName = device.name else {
            return
        }

        let startTime = NSDate.tb_currentTimestamp
        let sessions = firebase.childByAppendingPath("sessions")
        currentDemoSession = sessions.childByAppendingPath(sessionId.tb_sanitizeForFirebase())
        let session = currentDemoSession!
        
        // URL
        session.childByAppendingPath("shortUrl").setValue(shortUrl)
        
        // Start Time
        session.childByAppendingPath("startTime").setValue(NSNumber(longLong: startTime))
        
        // Contact Info
        let settings = ThunderBoardSettings()
        let contactInfo = session.childByAppendingPath("contactInfo")

        if let userName = settings.userName {
            contactInfo.childByAppendingPath("fullName").setValue(userName)
        }
        
        if let userEmail = settings.userEmail {
            contactInfo.childByAppendingPath("emailAddress").setValue(userEmail)
        }
        
        if let userTitle = settings.userTitle {
            contactInfo.childByAppendingPath("title").setValue(userTitle)
        }
        
        if let userPhone = settings.userPhone {
            contactInfo.childByAppendingPath("phoneNumber").setValue(userPhone)
        }
        
        // Device ID (included in contact info)
        contactInfo.childByAppendingPath("deviceName").setValue(deviceName)
        
        // User Preferences
        let temperatureUnits = session.childByAppendingPath("temperatureUnits")
        switch settings.temperature {
        case .Celsius:
            temperatureUnits.setValue(0)
        case .Fahrenheit:
            temperatureUnits.setValue(1)
        }
        
        let measurementUnits = session.childByAppendingPath("measurementUnits")
        switch settings.measurement {
        case .Metric:
            measurementUnits.setValue(0)
        case .Imperial:
            measurementUnits.setValue(1)
        }
        
        // Recent Session Info
        let recentSessions = firebase.childByAppendingPath("thunderboard/\(deviceId)/sessions")
        recentSessions.childByAppendingPath(String(startTime)).setValue(sessionId)
    }
    
    private func endStreamingSession() {
        currentDemoSession = nil
    }
    
    private var pendingDataPoints: [DemoStreamingDataPoint] = []
    private var pendingDataLock = NSLock()
    private func collectSampleData() {

        pendingDataLock.lock()
        defer {
            pendingDataLock.unlock()
        }

        if let s = sampleDemoData() {
            pendingDataPoints.appendContentsOf(s)
        }
    }
    
    private func reportCurrentData() {
        
        pendingDataLock.lock()
        defer {
            pendingDataLock.unlock()
        }
        let samples = pendingDataPoints
        pendingDataPoints.removeAll()
        
        guard let session = currentDemoSession else {
            log.error("No current session!")
            return
        }

        for sample in samples {
            let dataPath = session.childByAppendingPath(sample.path)
            let samplePath = dataPath.childByAppendingPath(sample.timestamp)
            samplePath.setValue(sample.data)
        }
        
        if self.firebaseConnected == false {
            self.output?.streamEncounteredError(ErrorFactory.streamingDisconnected())
        }
        else {
            self.output?.streamHeartbeat()
        }
    }

    func sampleDemoData() -> [DemoStreamingDataPoint]? {
        // empty implementation for base class
        return nil
    }
    
    //MARK:- Internal - Timers

    private var sampleTimer: WeakTimer?
    private var reportingTimer: WeakTimer?
    
    private func startPollingTimers() {
        log.info("starting polling timer")

        var frequency = sampleFrequency()
        sampleTimer = WeakTimer.scheduledTimer(frequency, repeats: true, action: { [weak self] () -> Void in
            self?.sampleTimerFired()
        })
        
        frequency = reportingFrequency()
        reportingTimer = WeakTimer.scheduledTimer(frequency, repeats: true, action: { [weak self] () -> Void in
            self?.reportTimerFired()
        })
    }
    
    private func stopPollingTimers() {
        log.info("stopping polling timer")
        sampleTimer = nil
        reportingTimer = nil
    }
    
    private func sampleTimerFired() {
        collectSampleData()
    }
    
    private func reportTimerFired() {
        reportCurrentData()
    }
    
}