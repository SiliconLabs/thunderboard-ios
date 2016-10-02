//
//  NSDataExtensions.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

extension NSData {
    func tb_getByteAtIndex(index: Int) -> UInt8 {
        var byte: UInt8 = 0
        subdataWithRange(NSRange(location: index, length: 1)).getBytes(&byte, length: 1)
        return byte
    }
}