//
//  EnvironmentDemoViewController.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class EnvironmentDemoViewController: DemoViewController, EnvironmentDemoInteractionOutput {

    var interaction: EnvironmentDemoInteraction?
    
    weak var temperatureViewController: EnvironmentCellViewController?
    weak var humidityViewController: EnvironmentCellViewController?
    weak var ambientLightViewController: EnvironmentCellViewController?
    weak var uvIndexViewController: EnvironmentCellViewController?
    
    let assetNameTemperature = "icn_demo_temp"
    let assetNameHumidity = "icn_demo_humidity"
    let assetNameAmbientLight = "icn_demo_ambient_light"
    let assetNameUvIndex = "icn_demo_uv_index"
    
    @IBOutlet weak var contentView: UIView?

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "temperatureSegue" {
            self.temperatureViewController = segue.destinationViewController as? EnvironmentCellViewController
        }
        
        if segue.identifier == "humiditySegue" {
            self.humidityViewController = segue.destinationViewController as? EnvironmentCellViewController
        }
        
        if segue.identifier == "ambientLightSegue" {
            self.ambientLightViewController = segue.destinationViewController as? EnvironmentCellViewController
        }
        
        if segue.identifier == "uvIndexSegue" {
            self.uvIndexViewController = segue.destinationViewController as? EnvironmentCellViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Environment"

        setupLayout()
        
        self.temperatureViewController?.titleLabel?.text = "TEMPERATURE"
        self.humidityViewController?.titleLabel?.text = "HUMIDITY"
        self.ambientLightViewController?.titleLabel?.text = "AMBIENT LIGHT"
        self.uvIndexViewController?.titleLabel?.text = "UV INDEX"
        
        initializeEnvironmentValueLabels()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tb_setNavigationBarStyleForDemo(.Environment)
        self.interaction?.updateView()
    }
    
    //MARK: - EnvironmentDemoInteractionOutput
    
    func updatedEnvironmentData(data: EnvironmentData) {
        if let temperature = data.temperature {
            updateTemperature(temperature)
        }
        
        if let humidity = data.humidity {
            updateHumidity(humidity)
        }
        
        if let ambientLight = data.ambientLight {
            updateAmbientLight(ambientLight)
        }
        
        if let uvIndex = data.uvIndex {
            updateUvIndex(uvIndex)
        }
    }
    
    //MARK: - Private
    
    private func setupLayout() {
        let constraint = NSLayoutConstraint(
            item: self.contentView!,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.ambientLightViewController?.view!,
            attribute: .Bottom,
            multiplier: 1,
            constant: 60)
        
        self.view.addConstraint(constraint)
    }
    
    private func updateTemperature(temperature: Temperature) {
        let settings = ThunderBoardSettings()
        
        switch settings.temperature {
        case .Fahrenheit:
            let temperatureInWholeDegrees = Int(temperature.tb_FahrenheitValue)
            self.temperatureViewController?.valueLabel?.text = "\(temperatureInWholeDegrees)°F"
        case .Celsius:
            let temperature = temperature.tb_roundToTenths()
            self.temperatureViewController?.valueLabel?.text = "\(temperature)°C"
        }
        
        let color = colorForTemperature(temperature)
        self.temperatureViewController?.imageView?.image = UIImage.tb_imageNamed(assetNameTemperature, color: color)
    }

    private func updateHumidity(humidity: Humidity) {
        let color    = colorForHumidity(humidity)
        let humidity = Int(humidity)
        self.humidityViewController?.imageView?.image = UIImage.tb_imageNamed(assetNameHumidity, color: color)
        self.humidityViewController?.valueLabel?.text = "\(humidity)%"
    }
    
    private func updateAmbientLight(ambientLight: Lux) {
        let color = colorForIlluminance(ambientLight)
        self.ambientLightViewController?.imageView?.image = UIImage.tb_imageNamed(assetNameAmbientLight, color: color)
        self.ambientLightViewController?.valueLabel?.text = "\(ambientLight.tb_toString(0)!) lx"
    }
    
    private func updateUvIndex(uvIndex: UVIndex) {
        let color = colorForUVIndex(uvIndex)
        self.uvIndexViewController?.imageView?.image = UIImage.tb_imageNamed(assetNameUvIndex, color: color)
        self.uvIndexViewController?.valueLabel?.text = "\(uvIndex)"
    }
    
    private func initializeEnvironmentValueLabels() {
        self.temperatureViewController?.valueLabel?.text = String.tb_placeholderText()
        self.humidityViewController?.valueLabel?.text = String.tb_placeholderText()
        self.ambientLightViewController?.valueLabel?.text = String.tb_placeholderText()
        self.uvIndexViewController?.valueLabel?.text = String.tb_placeholderText()

        let color = StyleColor.siliconGray
        self.temperatureViewController?.imageView?.image = UIImage.tb_imageNamed(assetNameTemperature, color: color)
        self.humidityViewController?.imageView?.image = UIImage.tb_imageNamed(assetNameHumidity, color: color)
        self.ambientLightViewController?.imageView?.image = UIImage.tb_imageNamed(assetNameAmbientLight, color: color)
        self.uvIndexViewController?.imageView?.image = UIImage.tb_imageNamed(assetNameUvIndex, color: color)
    }
    
    private func colorForTemperature(temp: Temperature) -> UIColor {
        let inf = Temperature.infinity
        switch temp {
        case 37.7 ..< inf:
            return StyleColor.red
        case 32.2 ..< 37.7:
            return StyleColor.redOrange
        case 26.6 ..< 32.2:
            return StyleColor.pink
        case 21.1 ..< 26.6:
            return StyleColor.yellowOrange
        case 15.5 ..< 21.1:
            return StyleColor.yellow
        case 10 ..< 15.5:
            return StyleColor.brightGreen
        case 4.4 ..< 10:
            return StyleColor.terbiumGreen
        case -1.1 ..< 4.4:
            return StyleColor.mediumGreen
        case -6.6 ..< -1.1:
            return StyleColor.lightBlue
        case -12.2 ..< -6.6:
            return StyleColor.blue
        case -17.7 ..< -12.2:
            return StyleColor.darkViolet
        case -23.3 ..< -17.7:
            return StyleColor.violet
        case -28.8 ..< -23.3:
            return StyleColor.darkGray
        case (-inf) ..< -28.8: fallthrough
        default:
            return StyleColor.gray
        }
    }
    
    private func colorForHumidity(humidity: Humidity) -> UIColor {
        let inf = Humidity.infinity
        switch humidity {
        case 65 ..< inf:
            return StyleColor.redOrange
        case 61 ..< 65:
            return StyleColor.bromineOrange
        case 56 ..< 61:
            return StyleColor.yellowOrange
        case 51 ..< 56:
            return StyleColor.yellow
        case 46 ..< 51:
            return StyleColor.terbiumGreen
        case (-inf) ..< 46: fallthrough
        default:
            return StyleColor.blue
        }
    }
    
    private func colorForIlluminance(lx: Lux) -> UIColor {
        let inf = Lux.infinity
        switch lx {
        case (-inf) ..< 41:
            return StyleColor.darkViolet
        case 41 ..< 81:
            return StyleColor.violet
        case 81 ..< 120:
            return StyleColor.lightViolet
        case 120 ..< 161:
            return StyleColor.whiteViolet
        case 161 ..< 201:
            return StyleColor.white
        case 201 ..< 301:
            return StyleColor.lightPeach
        case 301 ..< 501:
            return StyleColor.peachGold
        case 501 ..< 1001:
            return StyleColor.pink
        case 1001 ..< 10001:
            return StyleColor.bromineOrange
        case 10001 ..< inf: fallthrough
        default:
            return StyleColor.yellowOrange
        }
    }
    
    private func colorForUVIndex(uv: UVIndex) -> UIColor {
        let inf = UVIndex.infinity
        switch uv {
        case (-inf) ..< 3:
            return StyleColor.terbiumGreen
        case 3 ..< 6:
            return StyleColor.yellow
        case 6 ..< 8:
            return StyleColor.yellowOrange
        case 8 ..< 11:
            return StyleColor.redOrange
        case 11 ..< inf: fallthrough
        default:
            return StyleColor.violet
        }
    }
}
