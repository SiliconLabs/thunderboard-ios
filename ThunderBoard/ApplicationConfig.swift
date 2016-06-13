//
//  UIApplication+EnvironmentConfiguration.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class ApplicationConfig {
    
    // URL used for microsite links (sent in demo emails)
    class var ProductMicroSiteUrl: String {
        get { return "http://www.silabs.com" }
    }

    // Firebase IO Host ("your-application-0001.firebaseio.com")
    class var FirebaseIoHost: String {
        get { return "" }
    }
    
    // Firebase web app host ("your-application-0001.firebaseapp.com")
    class var FirebaseDemoHost: String {
        get { return "" }
    }

    // Firebase token (40 character string from your Firebase account)
    class var FirebaseToken: String {
        get { return "" }
    }
    
    // Hockey Token - (32 character string provided by Hockey for crash reporting)
    class var HockeyToken: String? {
        get { return nil }
    }
}
