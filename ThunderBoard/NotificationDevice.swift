//
//  NotificationDevice.swift
//  ThunderBoard
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
    private let codingName = "name"
    private let codingIdentifier = "identifier"
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey(codingName) as! String
        
        if let number = aDecoder.decodeObjectForKey(codingIdentifier) as? NSNumber {
            self.identifier = DeviceId(number.integerValue)
        }
        else {
            self.identifier = 0
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: codingName)
        
        let number = NSNumber(unsignedLongLong: identifier)
        aCoder.encodeObject(number, forKey: codingIdentifier)
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
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
