//
//  SharingActivityProvider.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class SharingActivityProvider : UIActivityItemProvider {

    fileprivate let thunderboardUrl = ApplicationConfig.ProductMicroSiteUrl
    fileprivate let settings = ThunderboardSettings()

    fileprivate var demoUrl: String
    init(url: String) {
        demoUrl = url
        super.init(placeholderItem: demoUrl)
    }
    
    override var item : Any {
        guard let activityType = self.activityType else {
            return demoUrl as AnyObject
        }
        
        switch activityType {
        case UIActivity.ActivityType.message:
            return smsMessageItem() as AnyObject
            
        case UIActivity.ActivityType.mail:
            return emailMessageItem() as AnyObject
            
        default:
            return demoUrl as AnyObject
        }
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Silicon Labs Demo Device Data"
    }
    
    fileprivate func smsMessageItem() -> String {
        //    Here is the link to access your Silicon Labs Demo Device synced data: <URL>
        //    Sent by <Name>, <Title>, <Email>, <Phone>
        
        return "Here is the link to access your Silicon Labs Demo Device synced data: \(demoUrl)"
    }
    
    fileprivate func emailMessageItem() -> String {
        //    Here is the link to access your synced data. It will remain active for 30 days after your sync ends.
        //    <URL>
        //    Learn more about Thunderboard at <URL>.
        
        var message = "Here is the link to access your synced data. It will remain active for 30 days after your sync ends.\n\n\(demoUrl)\n\n"
        message += "Learn more about Thunderboard at \(thunderboardUrl)\n\n"
        
        return message
    }
}
