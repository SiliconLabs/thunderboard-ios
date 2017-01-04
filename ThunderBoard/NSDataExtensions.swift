//
//  NSDataExtensions.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

extension Data {
    func tb_getByteAtIndex(_ index: Int) -> UInt8 {
        return self.subdata(in: index..<1).withUnsafeBytes { $0.pointee }
    }
}
