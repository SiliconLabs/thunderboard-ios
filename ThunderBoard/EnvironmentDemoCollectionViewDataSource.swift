//
//  EnvironmentDemoCollectionViewDataSource.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class EnvironmentDemoCollectionViewDataSource : NSObject, UICollectionViewDataSource {

    private struct EnvironmentCellData {
        let name: String
        let value: String
        let imageName: String
        let imageBackgroundColor: UIColor?
        
        enum Power {
            case NA
            case Off
            case On
        }
        let power: Power
    }
    
    private let cellIdentifier = "cell"
    private var capabilities: [DeviceCapability] = []
    private var cellData: [EnvironmentCellData] = []
    private typealias DataMapperFunction = ((EnvironmentData) -> EnvironmentCellData)
    private let dataMappers: [DeviceCapability:DataMapperFunction] = [
        .Temperature : { data in
            
            let title = "TEMPERATURE"
            if let temperature = data.temperature {

                let color = UIColor.colorForTemperature(temperature)
                
                let settings = ThunderboardSettings()
                var value = ""
                switch settings.temperature {
                case .Fahrenheit:
                    let temperatureInWholeDegrees = Int(temperature.tb_FahrenheitValue)
                    value = "\(temperatureInWholeDegrees)°F"
                case .Celsius:
                    let temperature = temperature.tb_roundToTenths()
                    value = "\(temperature)°C"
                }
                
                return EnvironmentCellData(name: title, value: value, imageName: "icn_demo_temp", imageBackgroundColor: color, power: .NA)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "icn_demo_temp_inactive", imageBackgroundColor: nil, power: .NA)
        },
        
        .Humidity : { data in
            
            let title = "HUMIDITY"
            if let humidity = data.humidity {

                let color = UIColor.colorForHumidity(humidity)
                let value = "\(Int(humidity))%"
                
                return EnvironmentCellData(name: title, value: value, imageName: "icn_demo_humidity", imageBackgroundColor: color, power: .NA)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "icn_demo_humidity_inactive", imageBackgroundColor: nil, power: .NA)
        },
        
        .AmbientLight : { data in
            
            let title = "AMBIENT LIGHT"
            if let ambientLight = data.ambientLight {
                
                let color = UIColor.colorForIlluminance(ambientLight)
                let value = "\(ambientLight.tb_toString(0)!) lx"
                
                return EnvironmentCellData(name: title, value: value, imageName: "icn_demo_ambient_light", imageBackgroundColor: color, power: .NA)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "icn_demo_ambient_light_inactive", imageBackgroundColor: nil, power: .NA)
        },
        
        .UVIndex : { data in
            
            let title = "UV INDEX"
            if let uvIndex = data.uvIndex {
                
                let color = UIColor.colorForUVIndex(uvIndex)
                let value = uvIndex.tb_toString(0) ?? ""
                
                return EnvironmentCellData(name: title, value: value, imageName: "icn_demo_uv_index", imageBackgroundColor: color, power: .NA)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "icn_demo_uv_index_inactive", imageBackgroundColor: nil, power: .NA)
        },
        
        .AirQualityCO2 : { data in
            let title = "CARBON DIOXIDE"
            if let co2 = data.co2 {
                if co2.enabled, let co2Value = co2.value {
                    let color = UIColor.colorForCO2(co2Value)
                    let value = "\(Int(co2Value)) ppm"

                    return EnvironmentCellData(name: title, value: value, imageName: "ic_carbon_dioxide", imageBackgroundColor: color, power: .On)
                }

                return EnvironmentCellData(name: title, value: "OFF", imageName: "ic_carbon_dioxide_inactive", imageBackgroundColor: nil, power: .Off)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "ic_carbon_dioxide_inactive", imageBackgroundColor: nil, power: .NA)
        },
        
        .AirQualityVOC : { data in
            let title = "VOCs"
            if let voc = data.voc {
                if voc.enabled, let vocValue = voc.value {
                    let color = UIColor.colorForVOC(vocValue)
                    let value = "\(Int(vocValue)) ppb"
                    
                    return EnvironmentCellData(name: title, value: value, imageName: "ic_voc", imageBackgroundColor: color, power: .On)
                }

                return EnvironmentCellData(name: title, value: "OFF", imageName: "ic_voc_inactive", imageBackgroundColor: nil, power: .Off)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "ic_voc_inactive", imageBackgroundColor: nil, power: .NA)
        },
        
        .AirPressure : { data in
            let title = "AIR PRESSURE"
            if let pressure = data.pressure {
                
                let color = UIColor.colorForAtmosphericPressure(pressure)
                let value = "\(Int(pressure)) mbar"
                
                return EnvironmentCellData(name: title, value: value, imageName: "ic_atmospheric_pressure", imageBackgroundColor: color, power: .NA)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "ic_atmospheric_pressure_inactive", imageBackgroundColor: nil, power: .NA)
        },
        
        .SoundLevel : { data in
            let title = "SOUND LEVEL"
            if let soundLevel = data.sound {
                
                let color = UIColor.colorForSoundLevel(soundLevel)
                let value = "\(Int(soundLevel)) dB"
                
                return EnvironmentCellData(name: title, value: value, imageName: "ic_sound_level", imageBackgroundColor: color, power: .NA)
            }
            
            return EnvironmentCellData(name: title, value: String.tb_placeholderText(), imageName: "ic_sound_level_inactive", imageBackgroundColor: nil, power: .NA)
        },
    ]
    
    // MARK: - Public (Internal)
    
    func registerCells(collectionView: UICollectionView) {
        collectionView.registerClass(EnvironmentDemoCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    func updateData(data: EnvironmentData, capabilities deviceCapabilities: Set<DeviceCapability>) {
        let capabilityOrder: [DeviceCapability] = [
            .Temperature,   .Humidity,
            .AmbientLight,  .UVIndex,
            .AirPressure,   .SoundLevel,
            .AirQualityCO2, .AirQualityVOC,
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
    
    func capabilityAtIndexPath(indexPath: NSIndexPath) -> DeviceCapability? {
        return capabilities[indexPath.row]
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! EnvironmentDemoCollectionViewCell
        let data = cellData[indexPath.row]
        let power: Bool? = {
            if data.power != .NA {
                return (data.power == .On) ? true : false
            }
            return nil
        }()

        cell.titleLabel.text = data.name
        cell.updateValue(data.value, imageName: data.imageName, backgroundColor: data.imageBackgroundColor, power: power)
        return cell
    }
}
