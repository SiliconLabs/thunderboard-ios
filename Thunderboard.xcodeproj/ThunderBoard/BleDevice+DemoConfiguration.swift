//
//  BleDevice+DemoConfiguration.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BleDevice {
    
    // TODO: cleanup (remove duplication between demo configurations)
    private func isNotificationProtected(characteristic: CBCharacteristic) -> Bool {
        return [
            CBUUID.BatteryLevel
            
        ].contains(characteristic.UUID)
    }


    private func allKnownCharacteristics() -> Set<CBUUID> {
        var result: Set<CBUUID> = []
        
        if let knownUUIDs = self.cbPeripheral.services?.flatMap({ $0.characteristics?.flatMap({ $0.UUID }) }).flatMap({$0}) {
            for uuid in knownUUIDs {
                result.insert(uuid)
            }
        }

        return result
    }
    
    
    private func waitForCharacteristics(uuids: Set<CBUUID>) -> AsyncOperation {

        let operation = AsyncOperation(block: { (operation: AsyncOperation) -> Void in
            repeat {

                let knownUUIDs = self.allKnownCharacteristics()
                let matches = uuids.intersect(knownUUIDs)
                if matches.count == uuids.count {
                    log.debug("found all characteristics")
                    break
                }
                else {
                    let missing = uuids.subtract(matches)
                    log.info("missing characteristics: \(missing)")
                }
                
                log.debug("waiting for characteristics")
                // TODO: remove sleep and inject operation into queue (linking dependencies)
                NSThread.sleepForTimeInterval(1)
            } while(self.connectionState == .Connected)
            
            operation.done()
        })
        
        return operation
    }
    

    func resetDemoConfiguration() {
        log.debug("Demo Reset Requested")
        
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        allCharacteristics.forEach({ characteristic in
            if characteristic.tb_supportsNotificationOrIndication() && !self.isNotificationProtected(characteristic) {
                log.debug("Disabling notification on \(characteristic.UUID)")
                queue.tb_addAsyncOperationBlock({ (operation: AsyncOperation) -> Void in

                    self.characteristicNotificationUpdateHook = { (updatedCharacteristic: CBCharacteristic) -> Void in
                        if updatedCharacteristic == characteristic {
                            log.debug("Received notification update for \(characteristic.UUID)")
                            self.characteristicNotificationUpdateHook = nil
                            operation.done()
                        }
                    }
                    
                    self.cbPeripheral?.setNotifyValue(false, forCharacteristic: characteristic)
                })
            }
        })
    }
    
    func configureIoDemo() {
        
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        // Notify Configuration Starting
        queue.tb_addAsyncOperationBlock { (operation: AsyncOperation) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.configurationDelegate?.configuringIoDemo()
                operation.done()
            })
        }
        
        // Enumerate services, characteristics
        let requiredCharacteristics: Set<CBUUID> = [
            CBUUID.Digital
        ]
        queue.addOperation(waitForCharacteristics(requiredCharacteristics))
        
        let completion = AsyncOperation(block: { (operation: AsyncOperation) -> Void in
            log.info("Finished IO configuration")
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                let connection = BleIoDemoConnection(device: self)
                self.configurationDelegate?.ioDemoReady(connection)
            })
        })
        
        // Enable notifications for the Digital characteristic
        queue.tb_addAsyncOperationBlock { (operation) -> Void in

            self.allCharacteristics.forEach({ characteristic in
                
                log.debug("checking \(characteristic.UUID)")
                if characteristic.tb_supportsNotificationOrIndication() && !self.isNotificationProtected(characteristic) {
                    
                    let notifyOperation = queue.tb_addAsyncOperationBlock({ (operation: AsyncOperation) -> Void in
                        
                        self.characteristicNotificationUpdateHook = { (updatedCharacteristic: CBCharacteristic) -> Void in
                            if updatedCharacteristic == characteristic {
                                log.debug("Received notification update for \(characteristic.UUID)")
                                self.characteristicNotificationUpdateHook = nil
                                operation.done()
                            }
                        }
                        
                        if requiredCharacteristics.contains(characteristic.UUID) {
                            log.debug("Updating notify for digital")
                            self.cbPeripheral.setNotifyValue(true, forCharacteristic: characteristic)
                        }
                            
                        else {
                            log.debug("disabling notify for \(characteristic.UUID)")
                            self.cbPeripheral.setNotifyValue(false, forCharacteristic: characteristic)
                        }
                    })
                    
                    completion.addDependency(notifyOperation)
                }
            })
            
            operation.done()
        }
        
        // add completion task
        queue.addOperation(completion)
        
        queue.suspended = false
    }
    
    func configureEnvironmentDemo() {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        // Notify Configuration Starting
        queue.tb_addAsyncOperationBlock { (operation: AsyncOperation) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.configurationDelegate?.configuringEnvironmentDemo()
                operation.done()
            })
        }
        
        // NOTE: the environmental demo polls the characteristics,
        // so we don't need to wait for discovery to occur.
        // HOWEVER, we need to wait for model and power (to determine if air quality should be shown)
        
        queue.tb_addAsyncOperationBlock { (operation) in
            while self.power == .Unknown {
                log.info("waiting for power source information")
                sleep(1)
            }
            
            while self.model == .Unknown {
                log.info("waiting for model information")
                sleep(1)
            }
            
            operation.done()
        }

        // Environmental characteristics do not notify - the demo connection class handles polling, so notify is disabled for all
        allCharacteristics.forEach({ characteristic in
            
            log.debug("checking \(characteristic.UUID)")
            if characteristic.tb_supportsNotificationOrIndication() && !self.isNotificationProtected(characteristic) {
                
                queue.tb_addAsyncOperationBlock({ (operation: AsyncOperation) -> Void in
                    
                    self.characteristicNotificationUpdateHook = { (updatedCharacteristic: CBCharacteristic) -> Void in
                        if updatedCharacteristic == characteristic {
                            log.debug("Received notification update for \(characteristic.UUID)")
                            self.characteristicNotificationUpdateHook = nil
                            operation.done()
                        }
                    }

                    log.debug("disabling notify for \(characteristic.UUID)")
                    self.cbPeripheral.setNotifyValue(false, forCharacteristic: characteristic)
                })
            }
        })
        
        // add completion task
        queue.tb_addAsyncOperationBlock({ (operation: AsyncOperation) -> Void in
            log.info("Finished Environment configuration")
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                let connection = BleEnvironmentDemoConnection(device: self)
                self.configurationDelegate?.environmentDemoReady(connection)
            })
            
        })
        
        queue.suspended = false

    }

    func configureMotionDemo() {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        // Notify Configuration Starting
        queue.tb_addAsyncOperationBlock { (operation: AsyncOperation) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.configurationDelegate?.configuringMotionDemo()
                operation.done()
            })
        }
        
        // wait for required characteristics to become available
        var requiredCharacteristics: Set<CBUUID> = [
            CBUUID.Command,
            CBUUID.OrientationMeasurement,
            CBUUID.AccelerationMeasurement,
        ]

        if capabilities.contains(.Revolutions) {
            requiredCharacteristics.insert(.CSCMeasurement)
            requiredCharacteristics.insert(.CSCControlPoint)
        }
        
        queue.addOperation(waitForCharacteristics(requiredCharacteristics))
        
        let completion = AsyncOperation(block: { operation in
            log.info("Finished Motion configuration")
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                let connection = BleMotionDemoConnection(device: self)
                self.configurationDelegate?.motionDemoReady(connection)
                operation.done()
            })
        })
        
        
        // Enable notifications for the Orientation, Acceleration, and Revolutions characteristics
        queue.tb_addAsyncOperationBlock({ operation in
            self.allCharacteristics.forEach({ characteristic in
                
                log.debug("checking \(characteristic.UUID)")
                
                if characteristic.tb_supportsNotificationOrIndication() && !self.isNotificationProtected(characteristic) {
                    
                    let notifyOperation = queue.tb_addAsyncOperationBlock({ (operation: AsyncOperation) -> Void in
                        
                        self.characteristicNotificationUpdateHook = { (updatedCharacteristic: CBCharacteristic) -> Void in
                            if updatedCharacteristic == characteristic {
                                log.debug("Received notification update for \(characteristic.UUID)")
                                self.characteristicNotificationUpdateHook = nil
                                operation.done()
                            }
                        }
                        
                        if requiredCharacteristics.contains(characteristic.UUID) {
                            log.debug("Enabling notify for \(characteristic.UUID)")
                            self.cbPeripheral.setNotifyValue(true, forCharacteristic: characteristic)
                        }
                            
                        else {
                            log.debug("disabling notify for \(characteristic.UUID)")
                            self.cbPeripheral.setNotifyValue(false, forCharacteristic: characteristic)
                        }
                    })
                    
                    completion.addDependency(notifyOperation)
                }
            })
            
            operation.done()
            
        })
        
        // add completion task
        queue.addOperation(completion)
        
        queue.suspended = false
    }
}
