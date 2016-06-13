//
//  Logging.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

typealias log = Logging
class Logging {
    
    enum Level: String {
        case Error = "error"
        case Info  = "info"
        case Debug = "debug"
    }
    
    #if DEBUG
    static var levels: [Level] = [.Error, .Info, .Debug]
    #else
    static var levels: [Level] = [.Error, .Info]
    #endif
    
    class func error(message: String, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        if levels.contains(.Error) {
            writeMessage(message, level: .Error, file: file, function: function, line: line)
        }
    }
    
    class func info(message: String, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        if levels.contains(.Info) {
            writeMessage(message, level: .Info, file: file, function: function, line: line)
        }
    }
    
    class func debug(message: String, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        if levels.contains(.Debug) {
            writeMessage(message, level: .Debug, file: file, function: function, line: line)
        }
    }
    
    private class func writeMessage(message: String, level: Level, file: String, function: String, line: Int) {
        let filename = NSString(string: file).pathComponents.last! as String
        NSLog("[\(level)] \(filename):\(line) \(function) \(message)")
    }
}