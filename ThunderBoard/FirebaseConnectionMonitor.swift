//
//  FirebaseConnectionMonitor.swift
//  Thunderboard
//
//  Copyright © 2017 Silicon Labs. All rights reserved.
//

import Foundation
import Firebase

enum AuthenticationStatus {
    case AuthSuccess
    case AuthFailed
}

class FirebaseConnectionMonitor {
    
    static let shared = FirebaseConnectionMonitor()
    
    let statusChangedNotification = NSNotification.Name(rawValue: "FirebaseMonitorConnectionStatusChanged")
    
    func checkAuth() {
        FirebaseConnectionMonitor.shared.authenticateFirebase()
    }
    
    var isConnected: Bool {
        return FirebaseConnectionMonitor.shared.connected
    }
    
    var authenticationStatus: AuthenticationStatus = .AuthFailed
    
    private var connected: Bool = false {
        didSet {
            guard oldValue != connected else { return }
            NotificationCenter.default.post(name: self.statusChangedNotification, object: nil)
        }
    }
    
    private func startObserving() {
        let connectedRef = Firebase(url: "https://\(ApplicationConfig.FirebaseIoHost)/.info/connected")
        connectedRef?.observe(.value, with: { snapshot in
            self.connected = (snapshot?.value as? Bool) ?? false
            print("Firebase connection status: ", self.connected)
        })
    }
    
    private func authenticateFirebase() {
        guard let url = URL(string: "https://\(ApplicationConfig.FirebaseIoHost)") else {
            self.authenticationStatus = .AuthFailed
            return
        }
        let firebase = Firebase(url: url.absoluteString)
        firebase?.auth(withCustomToken: ApplicationConfig.FirebaseToken, withCompletionBlock: { (fbError: Error?, authData: FAuthData?) -> Void in
            if fbError != nil {
                log.error("Firebase authentication error: \(String(describing: fbError))")
                self.authenticationStatus = .AuthFailed
            }
            else {
                log.info("Firebase authentication successful")
                self.authenticationStatus = .AuthSuccess
                self.startObserving()
            }
        })
    }
}
