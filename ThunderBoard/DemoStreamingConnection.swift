//
//  DemoStreamingConnection.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import Firebase

struct DemoStreamingDataPoint {
    var path: String
    var timestamp: String
    var data: Any
}

/// Base class implementation of streaming support. Each demo subclasses @c DemoStreamingConnection to inherit most functionality
class DemoStreamingConnection : DemoStreaming {
    
    /// The sharable URL (displays an HTML view into the live data)
    var demoURL: String?
    var urlShortener = IsgdShortener()
    fileprivate weak var output: DemoStreamingOutput?

    fileprivate var device: Device
    fileprivate var streamingEnabled: Bool = false
    fileprivate var firebase: Firebase?
    fileprivate var firebaseConnected: Bool {
        return FirebaseConnectionMonitor.shared.isConnected
    }
    
    fileprivate let firebaseIoHost   = ApplicationConfig.FirebaseIoHost
    fileprivate let firebaseDemoHost = ApplicationConfig.FirebaseDemoHost
    fileprivate let firebaseToken    = ApplicationConfig.FirebaseToken
    fileprivate let shareUrlTemplate = "https://__FIREBASEDEMOHOST__/#/__DEVICEID_/__SESSIONID__/__DEMOTYPE__"

    init(device: Device, output: DemoStreamingOutput?) {
        
        self.device = device
        self.output = output
        
        defer {
            self.output?.streamingEnabled(streamingEnabled)
        }
        
        guard FirebaseConnectionMonitor.shared.authenticationStatus == .AuthSuccess else {
            streamingEnabled = false
            return
        }
        
        // if Firebase configuration is valid, enable the feature
        guard let url = URL(string: "https://\(firebaseIoHost)") else {
            log.error("Firebase IO Host invalid - streaming disabled")
            streamingEnabled = false
            return
        }
        
        guard let _ = URL(string: "https://\(firebaseDemoHost)") else {
            log.error("Firebase demo host invalid - streaming disabled")
            streamingEnabled = false
            return
        }
        
        if firebaseToken.characters.count != 40 {
            log.error("Firebase token invalid - streaming disabled")
            streamingEnabled = false
            return
        }
        
        log.debug("Firebase configuration valid")
        
        streamingEnabled = FirebaseConnectionMonitor.shared.isConnected ? true : false
        
        log.debug("Streaming enabled at init: \(streamingEnabled)")
        
        self.firebase = Firebase(url: url.absoluteString)
    }
    
    //MARK: - DemoStreaming Protocol
    
    func startStreaming() {
        
        log.info("starting stream for device \(device)")
        let type = demoType()
        let deviceId = device.deviceIdentifier!
        let (sessionId, fullDemoUrl) = createNewSession(deviceId, demoType: type)
        
        let queue = OperationQueue()
        queue.isSuspended = true
        
        let start = queue.tb_addAsyncOperationBlock("Notify Stream Starting") { [weak self] (operation: AsyncOperation) -> Void in
            OperationQueue.main.addOperation({
                self?.output?.streamStarting(fullDemoUrl)
                operation.done()
            })
        }

        var error: Error? = nil
        let authentication = queue.tb_addAsyncOperationBlock("Firebase Authentication") { [weak self] (operation: AsyncOperation) -> Void in
            
            self?.firebase?.auth(withCustomToken: self?.firebaseToken, withCompletionBlock: { (fbError: Error?, authData: FAuthData?) -> Void in
                
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
            OperationQueue.main.addOperation({ () -> Void in
                guard let strongSelf = self else {
                    return
                }
                
                if error == nil {
                    if let url = strongSelf.demoURL {
                        strongSelf.beginStreamingSession(strongSelf.device, sessionId: sessionId, shortUrl: url)
                        strongSelf.startPollingTimers()
                    
                        strongSelf.output?.streamStarted(url)
                    } else {
                        log.error("Missing Demo URL, no error returned from API")
                    }
                }
                else {
                    strongSelf.output?.streamFailedToStart(error! as NSError)
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
        
        queue.isSuspended = false
    }
 
    func stopStreaming() {
        stopPollingTimers()
        
        endStreamingSession()
        
        // send remaining samples
        reportCurrentData()
        
        OperationQueue.main.addOperation({
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
    
    func sampleFrequency() -> TimeInterval {
        return TimeInterval(1.0)
    }
    
    func reportingFrequency() -> TimeInterval {
        return TimeInterval(1.0)
    }
    
    //MARK:- Internal - Streaming Data
    
    fileprivate var currentDemoSession: Firebase?
    fileprivate func createNewSession(_ deviceId: DeviceId, demoType: String) -> (sessionId: String, shareUrl: String) {

        let sessionId = UUID().uuidString
        let urlString = shareUrlTemplate.tb_stringByReplacingTokenPairs([
            "__FIREBASEDEMOHOST__" : firebaseDemoHost,
            "__DEVICEID_" : deviceId.toString(),
            "__SESSIONID__" : sessionId,
            "__DEMOTYPE__"  : demoType
        ])
        
        log.info("created session id \(sessionId) with url \(urlString)")
        return (sessionId, urlString)
    }
    
    fileprivate func beginStreamingSession(_ device: Device, sessionId: String, shortUrl: String) {
        
        guard let firebase = firebase, let deviceId = device.deviceIdentifier, let deviceName = device.name else {
            return
        }

        let startTime = Date.tb_currentTimestamp
        let sessions = firebase.child(byAppendingPath: "sessions")
        currentDemoSession = sessions?.child(byAppendingPath: sessionId.tb_sanitizeForFirebase())
        let session = currentDemoSession!
        
        // URL
        session.child(byAppendingPath: "shortUrl").setValue(shortUrl)
        
        // Start Time
        session.child(byAppendingPath: "startTime").setValue(NSNumber(value: startTime as Int64))
        
        // Contact Info
        let settings = ThunderboardSettings()
        let contactInfo = session.child(byAppendingPath: "contactInfo")

        if let userName = settings.userName {
            contactInfo?.child(byAppendingPath: "fullName").setValue(userName)
        }
        
        if let userEmail = settings.userEmail {
            contactInfo?.child(byAppendingPath: "emailAddress").setValue(userEmail)
        }
        
        if let userTitle = settings.userTitle {
            contactInfo?.child(byAppendingPath: "title").setValue(userTitle)
        }
        
        if let userPhone = settings.userPhone {
            contactInfo?.child(byAppendingPath: "phoneNumber").setValue(userPhone)
        }
        
        // Device ID (included in contact info)
        contactInfo?.child(byAppendingPath: "deviceName").setValue(deviceName)
        
        // User Preferences
        let temperatureUnits = session.child(byAppendingPath: "temperatureUnits")
        switch settings.temperature {
        case .celsius:
            temperatureUnits?.setValue(0)
        case .fahrenheit:
            temperatureUnits?.setValue(1)
        }
        
        let measurementUnits = session.child(byAppendingPath: "measurementUnits")
        switch settings.measurement {
        case .metric:
            measurementUnits?.setValue(0)
        case .imperial:
            measurementUnits?.setValue(1)
        }
        
        // Recent Session Info
        let recentSessions = firebase.child(byAppendingPath: "thunderboard/\(deviceId)/sessions")
        recentSessions?.child(byAppendingPath: String(startTime)).setValue(sessionId)
    }
    
    fileprivate func endStreamingSession() {
        currentDemoSession = nil
    }
    
    fileprivate var pendingDataPoints: [DemoStreamingDataPoint] = []
    fileprivate var pendingDataLock = NSLock()
    fileprivate func collectSampleData() {

        pendingDataLock.lock()
        defer {
            pendingDataLock.unlock()
        }

        if let s = sampleDemoData() {
            pendingDataPoints.append(contentsOf: s)
        }
    }
    
    fileprivate func reportCurrentData() {
        
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
            let dataPath = session.child(byAppendingPath: sample.path)
            let samplePath = dataPath?.child(byAppendingPath: sample.timestamp)
            samplePath?.setValue(sample.data)
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

    fileprivate var sampleTimer: WeakTimer?
    fileprivate var reportingTimer: WeakTimer?
    
    fileprivate func startPollingTimers() {
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
    
    fileprivate func stopPollingTimers() {
        log.info("stopping polling timer")
        sampleTimer = nil
        reportingTimer = nil
    }
    
    fileprivate func sampleTimerFired() {
        collectSampleData()
    }
    
    fileprivate func reportTimerFired() {
        reportCurrentData()
    }
    
}
