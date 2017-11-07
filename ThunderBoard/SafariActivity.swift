//
//  SafariActivity.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class SafariActivity : UIActivity {
    
    fileprivate var url: URL?
    
    override var activityType : UIActivityType? {
        return UIActivityType("com.silab.activity.safari")
    }
    
    override var activityTitle : String? {
        return "Safari"
    }
    
    override var activityImage : UIImage? {
        return UIImage(named: "safari")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        let urls = filterUrls(activityItems as [AnyObject])
        
        if let url = urls.first {
            self.url = url
        }
    }
    
    override func perform() {
        if let url = self.url {
            UIApplication.shared.openURL(url)
        }
    }
    
    //MARK: - Private
    
    fileprivate func filterUrls(_ activityItems: [AnyObject]) -> [URL] {
        let urls = activityItems.filter({
            if let _ = $0 as? URL {
                return true
            }
            
            if let _ = $0 as? String {
                return true
            }
            
            return false
        })
        
        return urls.map({
            if let url = $0 as? URL {
                return url
            }
            else {
                let urlString = $0 as! String
                return URL(string: urlString)!
            }

        })
    }
}
