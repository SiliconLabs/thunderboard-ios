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
        case UIActivityType.message:
            return smsMessageItem() as AnyObject
            
        case UIActivityType.mail:
            return emailMessageItem() as AnyObject
            
        default:
            return demoUrl as AnyObject
        }
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return "Silicon Labs Demo Device Data"
    }
    
    fileprivate func smsMessageItem() -> String {
        //    Here is the link to access your Silicon Labs Demo Device synced data: <URL>
        //    Sent by <Name>, <Title>, <Email>, <Phone>
        
        var message = "Here is the link to access your Silicon Labs Demo Device synced data: \(demoUrl)"
        
        if let name = settings.userName {
            message += "\n\nSent by \(name)"
            
            if let title = settings.userTitle {
                message += ", \(title)"
            }
            
            if let email = settings.userEmail {
                message += ", \(email)"
            }
            
            if let phone = settings.userPhone {
                message += ", \(phone)"
            }
        }
        
        return message
    }
    
    fileprivate func emailMessageItem() -> String {
        //    Here is the link to access your synced data. It will remain active for 30 days after your sync ends.
        //    <URL>
        //    Learn more about Thunderboard at <URL>.
        //    <Name>
        //    <Title>
        //    <Email>
        //    <Phone>
        
        var message = "Here is the link to access your synced data. It will remain active for 30 days after your sync ends.\n\n\(demoUrl)\n\n"
        message += "Learn more about Thunderboard at \(thunderboardUrl)\n\n"
        
        if let name = settings.userName {
            message += "\(name)\n"
            
            if let title = settings.userTitle {
                message += "\(title)\n"
            }
            
            if let email = settings.userEmail {
                message += "\(email)\n"
            }
            
            if let phone = settings.userPhone {
                message += "\(phone)\n"
            }
        }
        
        return message
    }
}
