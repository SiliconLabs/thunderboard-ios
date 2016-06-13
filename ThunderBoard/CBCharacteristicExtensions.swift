//
//  CBCharacteristicExtensions.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import CoreBluetooth

extension CBCharacteristicProperties : CustomStringConvertible {
    public var description : String {
        let strings = [
            "Broadcast",
            "Read",
            "WriteWithoutResponse",
            "Write",
            "Notify",
            "Indicate",
            "AuthenticatedSignedWrites",
            "ExtendedProperties",
            "NotifyEncryptionRequired",
            "IndicateEncryptionRequired",
        ]
        
        var propertyDescriptions = [String]()
        for (index, string) in strings.enumerate() where contains(CBCharacteristicProperties(rawValue: UInt(1 << index))) {
            propertyDescriptions.append(string)
        }
        
        return propertyDescriptions.description
    }
}

extension CBCharacteristic {
    
    func tb_supportsNotification() -> Bool {
        return self.properties.rawValue & CBCharacteristicProperties.Notify.rawValue != 0
    }
    
    func tb_supportsIndication() -> Bool {
        return self.properties.rawValue & CBCharacteristicProperties.Indicate.rawValue != 0
    }
    
    func tb_supportsRead() -> Bool {
        return self.properties.rawValue & CBCharacteristicProperties.Read.rawValue != 0
    }
    
    func tb_supportsWrite() -> Bool {
        return self.properties.rawValue & CBCharacteristicProperties.Write.rawValue != 0
    }

    func tb_int8Value() -> Int8? {
        if let data = self.value {
            var byte: Int8 = 0
            data.getBytes(&byte, length: 1)

            return byte
        }
        
        return nil
    }
    
    func tb_uint8Value() -> UInt8? {
        if let data = self.value {
            var byte: UInt8 = 0
            data.getBytes(&byte, length: 1)

            return byte
        }
        
        return nil
    }
    
    func tb_int16Value() -> Int16? {
        if let data = self.value {
            var value: Int16 = 0
            data.getBytes(&value, length: 2)
            
            return value
        }
        
        return nil
    }
    
    func tb_uint16Value() -> UInt16? {
        if let data = self.value {
            var value: UInt16 = 0
            data.getBytes(&value, length: 2)
            
            return value
        }
        
        return nil
    }
    
    func tb_uint32Value() -> UInt32? {
        if let data = self.value {
            var value: UInt32 = 0
            data.getBytes(&value, length: 4)
            return value
        }
        
        return nil
    }
    
    func tb_uint64value() -> UInt64? {
        if let data = self.value {
            var value: UInt64 = 0
            data.getBytes(&value, length: 8)
            return value
        }
        
        return nil
    }
    
    func tb_stringValue() -> String? {
        if let data = self.value {
            return String(data: data, encoding: NSUTF8StringEncoding)
        }
        
        return nil
    }
    
    func tb_hexStringValue() -> String? {
        guard let data = self.value else {
            return nil
        }
        
        let len = data.length
        let result = NSMutableString(capacity: len*2)
        var byteArray = [UInt8](count: len, repeatedValue: 0x0)
        data.getBytes(&byteArray, length:len)
        for (index, element) in byteArray.enumerate() {
            if index % 8 == 0 && index > 0 {
                result.appendFormat("\n")
            }
            result.appendFormat("%02x ", element)
        }
        
        return String(result)
    }
    
    func tb_hexDump() {
        if let hex = self.tb_hexStringValue() {
            log.debug("\(hex)")
        }
    }
    
    func tb_inclinationValue() -> ThunderBoardInclination? {
        if let data = self.value {
            if data.length >= 6 {
                var xDegreesTimes100: Int16 = 0;
                var yDegreesTimes100: Int16 = 0;
                var zDegreesTimes100: Int16 = 0;
                data.getBytes(&xDegreesTimes100, range: NSMakeRange(0, 2))
                data.getBytes(&yDegreesTimes100, range: NSMakeRange(2, 2))
                data.getBytes(&zDegreesTimes100, range: NSMakeRange(4, 2))
                let xDegrees = Degree(xDegreesTimes100) / 100.0;
                let yDegrees = Degree(yDegreesTimes100) / 100.0;
                let zDegrees = Degree(zDegreesTimes100) / 100.0;
                return ThunderBoardInclination(x: xDegrees, y: yDegrees, z: zDegrees)
            }
        }
        
        return nil
    }
    
    func tb_vectorValue() -> ThunderBoardVector? {
        if let data = self.value {
            if data.length >= 6 {
                var xAccelerationTimes1k: Int16 = 0;
                var yAccelerationTimes1k: Int16 = 0;
                var zAccelerationTimes1k: Int16 = 0;
                data.getBytes(&xAccelerationTimes1k, range: NSMakeRange(0, 2))
                data.getBytes(&yAccelerationTimes1k, range: NSMakeRange(2, 2))
                data.getBytes(&zAccelerationTimes1k, range: NSMakeRange(4, 2))
                let xAcceleration = α(xAccelerationTimes1k) / 1000.0;
                let yAcceleration = α(yAccelerationTimes1k) / 1000.0;
                let zAcceleration = α(zAccelerationTimes1k) / 1000.0;
                return ThunderBoardVector(x: xAcceleration, y: yAcceleration, z: zAcceleration)
            }
        }
        
        return nil
    }
    
    func tb_cscMeasurementValue() -> ThunderBoardCSCMeasurement? {
        if let data = self.value {
            if data.length >= 7 {
                var revolutionsSinceConnecting:            UInt32 = 0
                var secondsSinceConnectingTimes1024:       UInt16 = 0
                data.getBytes(&revolutionsSinceConnecting, range: NSMakeRange(1, 4))
                data.getBytes(&secondsSinceConnectingTimes1024, range: NSMakeRange(5, 2))
                let secondsSinceConnecting: NSTimeInterval = Double(secondsSinceConnectingTimes1024) / 1024
                return ThunderBoardCSCMeasurement(revolutions:UInt(revolutionsSinceConnecting), seconds:secondsSinceConnecting)
            }
        }
        
        return nil
    }
    
}
