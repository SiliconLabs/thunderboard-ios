//
//  UIApplication+Version.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

extension UIApplication {
    
    var tb_version: String {
        get {
            return tb_stringForBundleVersionKey("CFBundleShortVersionString")
        }
    }
    
    var tb_buildNumber: String {
        get {
            return tb_stringForBundleVersionKey("CFBundleVersion")
        }
    }
    
    func tb_stringForBundleVersionKey(key: String) -> String {
        if let version = self.tb_applicationInfoPlistEntry(key) as? String {
            return version
        }
        
        return "???"
    }
    
    func tb_applicationInfoPlistEntry(key: String) -> AnyObject? {
        return NSBundle.mainBundle().infoDictionary?[key]
    }
}
