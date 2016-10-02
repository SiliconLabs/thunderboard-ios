//
//  SafariActivity.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class SafariActivity : UIActivity {
    
    private var url: NSURL?
    
    override func activityType() -> String? {
        return "com.silab.activity.safari"
    }
    
    override func activityTitle() -> String? {
        return "Safari"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "safari")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        let urls = filterUrls(activityItems)
        
        if let url = urls.first {
            self.url = url
        }
    }
    
    override func performActivity() {
        if let url = self.url {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    //MARK: - Private
    
    private func filterUrls(activityItems: [AnyObject]) -> [NSURL] {
        let urls = activityItems.filter({
            if let _ = $0 as? NSURL {
                return true
            }
            
            if let _ = $0 as? String {
                return true
            }
            
            return false
        })
        
        return urls.map({
            if let url = $0 as? NSURL {
                return url
            }
            else {
                let urlString = $0 as! String
                return NSURL(string: urlString)!
            }

        })
    }
}
