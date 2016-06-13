//
//  BleManager+DiscoveryFiltering.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import CoreBluetooth

extension BleManager {
    
    func isSensorBoard(peripheral: CBPeripheral) -> Bool {

        if let name = peripheral.name {
            return name.containsString("Thunder")
        }
        
        return false
    }
}