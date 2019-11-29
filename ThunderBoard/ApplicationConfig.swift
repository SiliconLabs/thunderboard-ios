//
//  UIApplication+EnvironmentConfiguration.swift
//  ThunderBoard
//
//  Created by Thaddeus Ternes on 11/13/15.
//  Copyright © 2015 Silicon Labs. All rights reserved.
//

import UIKit

class ApplicationConfig {
    
    // URL used for microsite links (sent in demo emails)
    class var ProductMicroSiteUrl: String {
        get { return "http://www.silabs.com/thunderboard" }
    }

    // Silicon Labs Production
    class var FirebaseIoHost: String {
        get { return "" }
    }
    
    // Silicon Labs Production
    class var FirebaseDemoHost: String {
        get { return "" }
    }

    // Silicon Labs Production
    class var FirebaseToken: String {
        get { return "" }
    }
    
    // Disabled in Production
    class var HockeyToken: String? {
        get { return "" }
    }
}
