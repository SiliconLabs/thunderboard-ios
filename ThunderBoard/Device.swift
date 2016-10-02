//
//  Device.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

enum DeviceConnectionState {
    case Disconnected
    case Connecting
    case Connected
}

typealias DeviceId = UInt64
extension DeviceId {
    func toString() -> String {
        return "\(self)"
    }
}

enum DeviceModel {
    case Unknown
    case React
    case Sense
}

enum DeviceCapability {
    // IO
    case DigitalInput   // switches
    case DigitalOutput  // binary LEDs
    case RGBOutput      // RGB LEDs
    
    // Environment
    case Temperature
    case Humidity
    case AmbientLight
    case UVIndex
    case AirQualityCO2
    case AirQualityVOC
    case AirPressure
    case SoundLevel
    
    // Motion
    case Calibration    // Calibrate Control
    case Orientation
    case Acceleration
    case Revolutions    // Hall Effect
    
    // Device Details
    case PowerSource
}

enum PowerSource : Equatable {
    case Unknown
    case USB
    case GenericBattery(Int) // React
    
    // Specifc Batteries (Sense)
    case AA(Int) // also AAA
    case CoinCell(Int)
}

protocol Device : class, DemoConfiguration {
    var model: DeviceModel { get }
    var name: String? { get }
    var deviceIdentifier: DeviceId? { get }
    var RSSI: Int? { get }
    var power: PowerSource { get }
    var firmwareVersion: String? { get }
    var connectionState: DeviceConnectionState { get }
    var capabilities: Set<DeviceCapability> { get }
    
    weak var connectedDelegate: ConnectedDeviceDelegate? { get set }
    
    func ledColor(index: Int) -> LedStaticColor
}

func ==(lhs: PowerSource, rhs: PowerSource) -> Bool {
    switch (lhs, rhs) {
    case (.Unknown, .Unknown):
        return true
    case (.USB, .USB):
        return true
    case (.GenericBattery, .GenericBattery):
        return true
    case (.AA, .AA):
        return true
    case (.CoinCell, .CoinCell):
        return true
    default:
        return false
    }
}