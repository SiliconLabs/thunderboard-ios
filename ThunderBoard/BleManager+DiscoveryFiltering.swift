//
//  BleManager+DiscoveryFiltering.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import CoreBluetooth

extension BleManager {
    
    func isThunderboard(_ peripheral: CBPeripheral) -> Bool {
        guard let name = peripheral.name else {
            return false
        }
        
        return name.hasPrefix("Thunder") || name.hasPrefix("TBS")
    }
}
