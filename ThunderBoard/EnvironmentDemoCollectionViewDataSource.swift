//
//  EnvironmentDemoCollectionViewDataSource.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
import RxSwift

struct EnvironmentCellData {
    let name: String
    let value: String
    let imageName: String
    let imageBackgroundColor: UIColor?
    
    enum Power {
        case na
        case off
        case on
    }
    let power: Power
}

class EnvironmentDemoCollectionViewDataSource : NSObject {
    
    fileprivate typealias DataMapperFunction = ((EnvironmentData) -> EnvironmentCellData)
    fileprivate let capabilities: Variable<Set<DeviceCapability>> = Variable(Set())
    fileprivate let allViewModels = Variable<[EnvironmentDemoViewModel]>([])
    let activeViewModels: Observable<[EnvironmentDemoViewModel]>
    
    fileprivate static let capabilityOrder: [DeviceCapability] = [
        .temperature,       .humidity,
        .ambientLight,      .uvIndex,
        .airPressure,       .soundLevel,
        .airQualityCO2,     .airQualityVOC,
        .hallEffectFieldStrength, .hallEffectState
    ]
    
    fileprivate static let dataMappers: [DeviceCapability : DataMapperFunction] = [
        .temperature : { data in
            
            let title = "TEMPERATURE"
            if let temperature = data.temperature {

                let color = UIColor.colorForTemperature(temperature)
                
                let settings = ThunderboardSettings()
                var value = ""
                switch settings.temperature {
                case .fahrenheit:
                    let temperatureInWholeDegrees = Int(temperature.tb_FahrenheitValue)
                    value = "\(temperatureInWholeDegrees)°F"
                case .celsius:
                    let temperature = temperature.tb_roundToTenths()
                    value = "\(temperature)°C"
                }
                
                return EnvironmentCellData(name: title, value: value, imageName: "icn_demo_temp", imageBackgroundColor: color, power: .na)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "icn_demo_temp_inactive", imageBackgroundColor: nil, power: .na)
        },
        
        .humidity : { data in
            
            let title = "HUMIDITY"
            if let humidity = data.humidity {

                let color = UIColor.colorForHumidity(humidity)
                let value = "\(Int(humidity))%"
                
                return EnvironmentCellData(name: title, value: value, imageName: "icn_demo_humidity", imageBackgroundColor: color, power: .na)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "icn_demo_humidity_inactive", imageBackgroundColor: nil, power: .na)
        },
        
        .ambientLight : { data in
            
            let title = "AMBIENT LIGHT"
            if let ambientLight = data.ambientLight {
                
                let color = UIColor.colorForIlluminance(ambientLight)
                let value = "\(ambientLight.tb_toString(0)!) lx"
                
                return EnvironmentCellData(name: title, value: value, imageName: "icn_demo_ambient_light", imageBackgroundColor: color, power: .na)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "icn_demo_ambient_light_inactive", imageBackgroundColor: nil, power: .na)
        },
        
        .uvIndex : { data in
            
            let title = "UV INDEX"
            if let uvIndex = data.uvIndex {
                
                let color = UIColor.colorForUVIndex(uvIndex)
                let value = uvIndex.tb_toString(0) ?? ""
                
                return EnvironmentCellData(name: title, value: value, imageName: "icn_demo_uv_index", imageBackgroundColor: color, power: .na)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "icn_demo_uv_index_inactive", imageBackgroundColor: nil, power: .na)
        },
        
        .airQualityCO2 : { data in
            let title = "CARBON DIOXIDE"
            if let co2 = data.co2 {
                if co2.enabled, let co2Value = co2.value {
                    let color = UIColor.colorForCO2(co2Value)
                    let value = "\(Int(co2Value)) ppm"

                    return EnvironmentCellData(name: title, value: value, imageName: "ic_carbon_dioxide", imageBackgroundColor: color, power: .on)
                }

                return EnvironmentCellData(name: title, value: "OFF", imageName: "ic_carbon_dioxide_inactive", imageBackgroundColor: nil, power: .off)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "ic_carbon_dioxide_inactive", imageBackgroundColor: nil, power: .na)
        },
        
        .airQualityVOC : { data in
            let title = "VOCs"
            if let voc = data.voc {
                if voc.enabled, let vocValue = voc.value {
                    let color = UIColor.colorForVOC(vocValue)
                    let value = "\(Int(vocValue)) ppb"
                    
                    return EnvironmentCellData(name: title, value: value, imageName: "ic_voc", imageBackgroundColor: color, power: .on)
                }

                return EnvironmentCellData(name: title, value: "OFF", imageName: "ic_voc_inactive", imageBackgroundColor: nil, power: .off)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "ic_voc_inactive", imageBackgroundColor: nil, power: .na)
        },
        
        .airPressure : { data in
            let title = "AIR PRESSURE"
            if let pressure = data.pressure {
                
                let color = UIColor.colorForAtmosphericPressure(pressure)
                let value = "\(Int(pressure)) mbar"
                
                return EnvironmentCellData(name: title, value: value, imageName: "ic_atmospheric_pressure", imageBackgroundColor: color, power: .na)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "ic_atmospheric_pressure_inactive", imageBackgroundColor: nil, power: .na)
        },
        
        .soundLevel : { data in
            let title = "SOUND LEVEL"
            if let soundLevel = data.sound {
                
                let color = UIColor.colorForSoundLevel(soundLevel)
                let value = "\(Int(soundLevel)) dB"
                
                return EnvironmentCellData(name: title, value: value, imageName: "ic_sound_level", imageBackgroundColor: color, power: .na)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "ic_sound_level_inactive", imageBackgroundColor: nil, power: .na)
        },

        .hallEffectState : { data in
            let title = "DOOR STATE"
            if let hallEffectState = data.hallEffectState {

                let color = UIColor.colorForHallEffectState(hallEffectState)
                let value: String
                switch hallEffectState {
                case .closed:
                    value = "Closed"
                case .open:
                    value = "Opened"
                case .tamper:
                    value = "Tampered\nTap to Reset"
                }
                let imageName = UIImage.imageNameForHallEffectState(hallEffectState)
                return EnvironmentCellData(name: title, value: value, imageName: imageName, imageBackgroundColor: color, power: .na)
            }

            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "ic_atmospheric_pressure", imageBackgroundColor: nil, power: .na)
        },

        .hallEffectFieldStrength : { data in
            let title = "MAGNETIC FIELD"
            if let hallEffectFieldStrength = data.hallEffectFieldStrength {

                let color = UIColor.colorForHallEffectFieldStrength(mT: hallEffectFieldStrength)
                let value = "\(hallEffectFieldStrength) uT"
                return EnvironmentCellData(name: title, value: value, imageName: "icn_demo_magnetic_field", imageBackgroundColor: color, power: .na)
            }

            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "icn_demo_magnetic_field", imageBackgroundColor: nil, power: .na)
        },
    ]
    
    var currentHallEffectState: HallEffectState? = nil
    
    override init() {
        
        allViewModels.value = EnvironmentDemoCollectionViewDataSource.capabilityOrder.flatMap { capability in
            guard let data = EnvironmentDemoCollectionViewDataSource.dataMappers[capability]?(EnvironmentData()) else {
                return nil
            }
            let viewModel = EnvironmentDemoViewModel(capability: capability)
            viewModel.updateData(cellData: data)
            return viewModel
        }
        
        activeViewModels = Observable.combineLatest(allViewModels.asObservable(), capabilities.asObservable().distinctUntilChanged())
            .map { viewModels, capabilities in
                return viewModels.filter({ capabilities.contains($0.capability) })
        }
        
        super.init()
    }
    
    // MARK: - Public (Internal)
    
    func updateData(_ data: EnvironmentData, capabilities deviceCapabilities: Set<DeviceCapability>) {
        capabilities.value = deviceCapabilities
        
        allViewModels.value.forEach { viewModel in
            guard let cellData = EnvironmentDemoCollectionViewDataSource.dataMappers[viewModel.capability]?(data) else {
                return
            }
            
            viewModel.updateData(cellData: cellData)
        }
        
        if let hallEffectState = data.hallEffectState {
            currentHallEffectState = hallEffectState
        }
    }
}
