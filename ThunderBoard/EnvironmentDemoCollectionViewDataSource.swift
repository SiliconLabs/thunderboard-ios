//
//  EnvironmentDemoCollectionViewDataSource.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class EnvironmentDemoCollectionViewDataSource : NSObject, UICollectionViewDataSource {

    fileprivate struct EnvironmentCellData {
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
    
    fileprivate let cellIdentifier = "cell"
    fileprivate var capabilities: [DeviceCapability] = []
    fileprivate var cellData: [EnvironmentCellData] = []
    fileprivate typealias DataMapperFunction = ((EnvironmentData) -> EnvironmentCellData)
    fileprivate let dataMappers: [DeviceCapability:DataMapperFunction] = [
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
                    let temperature = round(temperature * 10.0) / 10.0
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
    ]
    
    // MARK: - Public (Internal)
    
    func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(EnvironmentDemoCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    func updateData(_ data: EnvironmentData, capabilities deviceCapabilities: Set<DeviceCapability>) {
        let capabilityOrder: [DeviceCapability] = [
            .temperature,   .humidity,
            .ambientLight,  .uvIndex,
            .airPressure,   .soundLevel,
            .airQualityCO2, .airQualityVOC,
        ]
        
        capabilities = capabilityOrder.flatMap({
            return deviceCapabilities.contains($0) ? $0 : nil
        })
        
        cellData = capabilityOrder.flatMap({ capability in
            if !deviceCapabilities.contains(capability) {
                return nil
            }
            
            guard let mapper = dataMappers[capability] else {
                fatalError("developer error - define data mapper for all supported capabilities!")
            }
            
            return mapper(data)
        })
    }
    
    func capabilityAtIndexPath(_ indexPath: IndexPath) -> DeviceCapability? {
        return capabilities[indexPath.row]
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! EnvironmentDemoCollectionViewCell
        let data = cellData[indexPath.row]
        let power: Bool? = {
            if data.power != .na {
                return (data.power == .on) ? true : false
            }
            return nil
        }()

        cell.titleLabel.text = data.name
        cell.updateValue(data.value, imageName: data.imageName, backgroundColor: data.imageBackgroundColor, power: power)
        return cell
    }
}
