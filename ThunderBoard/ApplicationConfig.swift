//
//  UIApplication+EnvironmentConfiguration.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class ApplicationConfig {
    
    // URL used for microsite links (sent in demo emails)
    class var ProductMicroSiteUrl: String {
        get { return "https://www.silabs.com/thunderboard" }
    }

    // Firebase IO Host ("your-application-0001.firebaseio.com")
    class var FirebaseIoHost: String {
        get { return "thundercloud-40c56.firebaseio.com" }
    }
    
    // Firebase web app host ("your-application-0001.firebaseapp.com")
    class var FirebaseDemoHost: String {
        get { return "thundercloud-40c56.firebaseapp.com" }
    }

    // Firebase token (40 character string from your Firebase account)
    class var FirebaseToken: String {
        get { return "wcW6Q9EiGebuaG8AGpeIu4BwndQkCJEtooHIY3xl" }
    }
    
    // Hockey Token - (32 character string provided by Hockey for crash reporting)
    class var HockeyToken: String? {
        get { return nil }
    }
}
