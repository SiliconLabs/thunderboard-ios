//
//  ThunderboardTypes.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

let ThunderboardBeaconId = NSUUID(UUIDString: "CEF797DA-2E91-4EA4-A424-F45082AC0682")!

enum ThunderboardDemo: Int {
    case Motion
    case Environment
    case IO
}

enum MotionDemoModel: Int {
    case Board
    case Car
}

typealias Degree      = Float
typealias Radian      = Float
typealias Meters      = Float
typealias Centimeters = Float
typealias Inches      = Float
typealias Feet        = Float

enum LedState {
    case Digital(Bool, LedStaticColor)
    case RGB(Bool, LedRgb)
}

enum LedStaticColor {
    case Red
    case Green
    case Blue
}

struct LedRgb {
    let red: Float
    let green: Float
    let blue: Float
}

extension LedState {
    func toggle() -> LedState {
        switch self {
        case .Digital(let on, let color):
            return .Digital(!on, color)
        case .RGB(let on, let color):
            return .RGB(!on, color)
        }
    }
    
    func setColor(color: LedRgb) -> LedState {
        switch self {
        case .Digital:
            return self
        case .RGB(let on, _):
            return .RGB(on, color)
        }
    }
    
    func setColor(red: Float, green: Float, blue: Float) -> LedState {
        return setColor(LedRgb(red: red, green: green, blue: blue))
    }
    
    var on: Bool {
        switch self {
        case .Digital(let on, _):
            return on
        case .RGB(let on, _):
            return on
        }
    }
}

extension Degree {
    func tb_toRadian() -> Radian {
        return self * Float(M_PI) / 180.0
    }
    
    func tb_toString(maximumDecimalPlaces: Int, minimumDecimalPlaces: Int = 0) -> String? {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.minimumFractionDigits = minimumDecimalPlaces
        formatter.maximumFractionDigits = maximumDecimalPlaces
        return formatter.stringFromNumber(NSNumber(float: self))
    }
}

extension Double {
    func tb_toString(precision: Int) -> String? {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = precision
        return formatter.stringFromNumber(NSNumber(double: self))
    }
}

extension Meters {
    func tb_toInches() -> Inches {
        return self * Float(39.3701)
    }
    func tb_toFeet() -> Feet {
        return self * Float(3.28084)
    }
}

struct ThunderboardInclination {
    let x, y, z: Degree
    
    init() {
        x = 0
        y = 0
        z = 0
    }
    
    init(x: Degree, y: Degree, z: Degree) {
        self.x = x;
        self.y = y;
        self.z = z;
    }
}

typealias α = Float

struct ThunderboardVector {
    let x, y, z: α
    
    init() {
        x = 0
        y = 0
        z = 0
    }
    
    init(x: α, y: α, z: α) {
        self.x = x;
        self.y = y;
        self.z = z;
    }

}

struct ThunderboardCSCMeasurement {
    let revolutionsSinceConnecting: UInt
    let secondsSinceConnecting:     NSTimeInterval
    
    init() {
        revolutionsSinceConnecting  = 0;
        secondsSinceConnecting = 0;
    }
    
    init(revolutions: UInt, seconds: NSTimeInterval) {
        revolutionsSinceConnecting  = revolutions
        secondsSinceConnecting      = seconds
    }
}

enum MeasurementUnits: Int {
    case Metric
    case Imperial
}

enum TemperatureUnits: Int {
    case Celsius
    case Fahrenheit
}

typealias Temperature = Double
typealias Humidity = Double
typealias Lux = Double
typealias UVIndex = Double
typealias AirQualityCO2 = Double
typealias AirQualityVOC = Double
typealias SoundLevel = Double
typealias AtmosphericPressure = Double
    
extension Temperature {
    var tb_FahrenheitValue: Temperature {
        // T(°F) = T(°C) × 9/5 + 32
        get { return (self * (9/5)) + 32 }
    }

    func tb_roundToTenths() -> Temperature {
        return round(self * 10.0) / 10.0
    }
}

struct EnvironmentData {
    var temperature: Temperature?
    var humidity: Humidity?
    var ambientLight: Lux?
    var uvIndex: UVIndex?
    var co2: CarbonDioxideReading?
    var voc: VolatileOrganicCompoundsReading?
    var sound: SoundLevel?
    var pressure: AtmosphericPressure?
}

struct CarbonDioxideReading {
    let enabled: Bool
    let value: AirQualityCO2?
}

struct VolatileOrganicCompoundsReading {
    let enabled: Bool
    let value: AirQualityVOC?
}

struct ThunderboardWheel {
    var diameter:                               Meters
    var revolutionsSinceConnecting:             UInt           = 0
    var secondsSinceConnecting:                 NSTimeInterval = 0

    private let rotationTimeOut:                UInt           = 12
    private var previousSecondsSinceConnecting: NSTimeInterval = 0
    private var previousRevolutions:            UInt           = 0
    private let secondsPerMinute:               Float          = 60
    
    var distance: Meters {
        
        get {
            return Meters(Double(revolutionsSinceConnecting) * M_PI * Double(diameter))
        }
    }
    
    var rpm: Float {
    
        get {
            if deltaSeconds() == 0 {
                return 0.0
            } else {
                return Float(Double(deltaRevolutions()) / deltaSeconds() * Double(secondsPerMinute))
            }
        }
    }

    var speedInMetersPerSecond: Float {
        
        get {
            if deltaSeconds() == 0 {
                return 0.0
            } else {
                let distance = Meters(deltaRevolutions()) * Float(M_PI) * diameter
                let distancePerSecond = distance / Float(deltaSeconds())
                return distancePerSecond
            }
        }
    }
    
    init(diameter: Meters) {
        self.diameter = diameter
    }

    private var countOfRepeatedSameValues: UInt = 0
    
    mutating func updateRevolutions(cumulativeRevolutions: UInt, cumulativeSecondsSinceConnecting: NSTimeInterval) {
        if cumulativeRevolutions != revolutionsSinceConnecting {
            previousSecondsSinceConnecting = secondsSinceConnecting
            previousRevolutions            = revolutionsSinceConnecting
            revolutionsSinceConnecting     = cumulativeRevolutions
            secondsSinceConnecting         = cumulativeSecondsSinceConnecting
            countOfRepeatedSameValues      = 0
        } else {
            countOfRepeatedSameValues += 1
            if countOfRepeatedSameValues >= rotationTimeOut {
                previousSecondsSinceConnecting = secondsSinceConnecting
                previousRevolutions            = revolutionsSinceConnecting
            }
        }
    }
    
    mutating func reset() {
        revolutionsSinceConnecting     = 0
        secondsSinceConnecting         = 0
        previousRevolutions            = 0
        previousSecondsSinceConnecting = 0
    }
    
    private func deltaRevolutions() -> UInt {
        var delta: UInt = 0
        if revolutionsSinceConnecting > previousRevolutions {
            delta = revolutionsSinceConnecting - previousRevolutions
        }
        return delta
    }
    
    private func deltaSeconds() -> NSTimeInterval {
        return secondsSinceConnecting - previousSecondsSinceConnecting
    }
}
