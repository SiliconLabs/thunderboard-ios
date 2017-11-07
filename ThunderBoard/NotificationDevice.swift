//
//  NotificationDevice.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class NotificationDevice : NSObject, NSCoding {
    var name: String
    var identifier: DeviceId
    
    enum Status : String {
        case NotConnected = "Not Connected"
        case Connected    = "Connected"
        case Found        = "Found"
    }
    
    var status: Status = .NotConnected
    
    init(name: String, identifier: DeviceId) {
        self.name = name
        self.identifier = identifier
    }
    
    override var debugDescription: String {
        get { return "name=\(name) identifier=\(identifier) status=\(status)" }
    }
    
    //MARK: NSCoding
    fileprivate let codingName = "name"
    fileprivate let codingIdentifier = "identifier"
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: codingName) as! String
        
        if let number = aDecoder.decodeObject(forKey: codingIdentifier) as? NSNumber {
            self.identifier = DeviceId(number.intValue)
        }
        else {
            self.identifier = 0
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: codingName)
        
        let number = NSNumber(value: identifier as UInt64)
        aCoder.encode(number, forKey: codingIdentifier)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? NotificationDevice {
            return self.identifier == object.identifier &&
                self.name == object.name
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return identifier.hashValue
    }
}
