//
//  CBUUIDExtensions.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import CoreBluetooth

extension CBUUID {
    
    //MARK:- Service Identifiers
    
    /// Generic Access Service (org.bluetooth.service.generic_access)
    class var GenericAccess: CBUUID {
        get { return CBUUID(string: "0x1800") }
    }
    
    /// Device Information (org.bluetooth.service.device_information)
    class var DeviceInformation: CBUUID {
        get { return CBUUID(string: "0x180A") }
    }
    
    /// Battery Info Service (org.bluetooth.service.battery_service)
    class var BatteryService: CBUUID {
        get { return CBUUID(string: "0x180F") }
    }
    
    /// Environmental Sensing (org.bluetooth.service.environmental_sensing)
    class var EnvironmentalSensing: CBUUID {
        get { return CBUUID(string: "0x181A") }
    }
    
    /// Cycling Speed and Cadence (org.bluetooth.service.cycling_speed_and_cadence)
    class var CyclingSpeedAndCadence: CBUUID {
        get { return CBUUID(string: "0x1816") }
    }
    
    /// Inertial Measurement (custom) (aka Acceleration and Orientation)
    class var InertialMeasurement: CBUUID {
        get { return CBUUID(string: "0xa4e649f4-4be5-11e5-885d-feff819cdc9f") }
    }
    
    /// Automation IO (org.bluetooth.service.automation_io)
    class var AutomationIO: CBUUID {
        get { return CBUUID(string: "0x1815") }
    }
    
    class var IndoorAirQualityCustom: CBUUID {
        get { return CBUUID(string: "0xefd658ae-c400-ef33-76e7-91b00019103b") }
    }
    
    class var PowerSourceServiceCustom: CBUUID {
        get { return CBUUID(string: "EC61A454-ED00-A5E8-B8F9-DE9EC026EC51") }
    }
    
    
    // ---------------------------------------------------------------------------------------
    // MARK:- Characteristic Identifiers
    // ---------------------------------------------------------------------------------------
    
    //
    // Generic Access Characteristics
    //

    /// Manufacturer Name (org.bluetooth.characteristic.gap.???)
    class var ManufacturerName: CBUUID {
        get { return CBUUID(string: "0x2A29") }
    }
    
    /// Model Number (org.bluetooth.characteristic.gap.???)
    class var ModelNumber: CBUUID {
        get { return CBUUID(string: "0x2A24") }
    }
    
    /// Hardware Revision (org.bluetooth.characteristic.gap.???)
    class var HardwareRevision: CBUUID {
        get { return CBUUID(string: "0x2A27") }
    }
    
    /// Firmware Revision (org.bluetooth.characteristic.gap.???)
    class var FirmwareRevision: CBUUID {
        get { return CBUUID(string: "0x2A26") }
    }
    
    class var SystemIdentifier: CBUUID {
        get { return CBUUID(string: "0x2A23") }
    }
    
    //
    // Battery Characteristics
    //
    
    /// Battery Level Characteristic (org.bluetooth.characteristic.battery_level)
    class var BatteryLevel: CBUUID {
        get { return CBUUID(string: "0x2A19") }
    }

    class var PowerSourceCharacteristicCustom: CBUUID {
        get { return CBUUID(string: "EC61A454-ED01-A5E8-B8F9-DE9EC026EC51") }
    }

    //
    // Environmental Sensing Characteristics
    //
    
    /// Humidity (org.bluetooth.characteristic.humidity)
    class var Humidity: CBUUID {
        get { return CBUUID(string: "0x2A6F") }
    }
    
    ///  Temperature (org.bluetooth.characteristic.temperature)
    class var Temperature: CBUUID {
        get { return CBUUID(string: "0x2A6E") }
    }
    
    // UV Index (org.bluetooth.characteristic.uv_index)
    class var UVIndex: CBUUID {
        get { return CBUUID(string: "0x2A76") }
    }
    
    class var Pressure: CBUUID {
        get { return CBUUID(string: "0x2A6D") }
    }
    
    /// Ambient Light (custom)
    class var AmbientLight: CBUUID {
        get { return CBUUID(string: "0xc8546913-bfd9-45eb-8dde-9f8754f4a32e") }
    }
    
    /// Sound Level (sense)
    class var SoundLevelCustom: CBUUID {
        get { return CBUUID(string: "0xC8546913-BF02-45EB-8DDE-9F8754F4A32E") }
    }
    
    /// Environment Control Point (sense)
    class var SenseEnvironmentControlPointCustom: CBUUID {
        get { return CBUUID(string: "0xC8546913-BF03-45EB-8DDE-9F8754F4A32E") }
    }

    //
    // Sense Indoor Air Quality Service
    //
    
    /// Air Quality: Carbon Dioxide (sense)
    class var SenseAirQualityCarbonDioxide: CBUUID {
        get { return CBUUID(string: "0xefd658ae-c401-ef33-76e7-91b00019103b") }
    }
    
    /// Air Quality: Volatile Organic Compounds
    class var SenseAirQualityVolatileOrganicCompounds: CBUUID {
        get { return CBUUID(string: "0xefd658ae-c402-ef33-76e7-91b00019103b") }
    }
    
    /// Air Quality Control Point
    class var SenseAirQualityControlPoint: CBUUID {
        get { return CBUUID(string: "0xefd658ae-c403-ef33-76e7-91b00019103b") }
    }

    
    //
    // Cycling Speed and Cadence Characteristics
    //
    
    /// CSC Control Point (org.bluetooth.characteristic.sc_control_point)
    class var CSCControlPoint: CBUUID {
        get { return CBUUID(string: "0x2A55") }
    }
    
    /// CSC Measurement (org.bluetooth.characteristic.csc_measurement)
    class var CSCMeasurement: CBUUID {
        get { return CBUUID(string: "0x2A5B") }
    }
    
    /// CSC Feature (org.bluetooth.characteristic.csc_feature)
    class var CSCFeature: CBUUID {
        get { return CBUUID(string: "0x2A5C") }
    }
    
    //
    // Inertial Measurement Characteristics
    //
    
    /// Acceleration Measurement (custom)
    class var AccelerationMeasurement: CBUUID {
        get { return CBUUID(string: "0xc4c1f6e2-4be5-11e5-885d-feff819cdc9f") }
    }
    
    /// Orientation Measurement (custom)
    class var OrientationMeasurement: CBUUID {
        get { return CBUUID(string: "0xb7c4b694-bee3-45dd-ba9f-f3b5e994f49a") }
    }

    /// Command (custom)
    class var Command: CBUUID {
        get { return CBUUID(string: "0x71e30b8c-4131-4703-b0a0-b0bbba75856b") }
    }
    
    //
    // Digital Characteristics
    //

    /// Digital (org.bluetooth.characteristic.digital)
    class var Digital: CBUUID {
        get { return CBUUID(string: "0x2A56") }
    }
    
    /// Characteristic Presentation Format (org.bluetooth.descriptor.gatt.characteristic_presentation_format)
    class var CharacteristicPresentationFormat: CBUUID {
        get { return CBUUID(string: "0x2904") }
    }
    
    /// Number of Digitals (org.bluetooth.descriptor.number_of_digitals)
    class var NumberOfDigitals: CBUUID {
        get { return CBUUID(string: "0x2909") }
    }
    
    class var SenseRGBOutput: CBUUID {
        get { return CBUUID(string: "FCB89C40-C603-59F3-7DC3-5ECE444A401B") }
    }
}
