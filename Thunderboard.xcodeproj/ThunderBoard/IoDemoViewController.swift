//
//  IODemoViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class IoDemoViewController: DemoViewController, IoDemoInteractionOutput {
    
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var switchesLabel: StyledLabel!
    @IBOutlet weak var switchesView: UIView!
    
    @IBOutlet weak var switch1View: ButtonSpinner!
    @IBOutlet weak var switch1OnOffLabel: StyledLabel!
    
    @IBOutlet weak var switch2View: ButtonSpinner!
    @IBOutlet weak var switch2OnOffLabel: StyledLabel!
    
    @IBOutlet weak var lightsLabel: StyledLabel!
    @IBOutlet weak var lightsView: UIView!

    @IBOutlet weak var light1Button: UIButton!
    @IBOutlet weak var light1OnOffLabel: StyledLabel!

    @IBOutlet weak var light2Button: UIButton!
    @IBOutlet weak var light2OnOffLabel: StyledLabel!
    
    @IBOutlet weak var rgbLightsView: UIView?
    
    @IBOutlet weak var rgbButton: UIButton?
    @IBOutlet weak var rgbStateLabel: StyledLabel?
    
    @IBOutlet weak var colorLabel: StyledLabel?
    @IBOutlet weak var colorSlider: UISlider?
    @IBOutlet weak var colorHueView: HueGradientView?
    
    @IBOutlet weak var brightnessLabel: StyledLabel?
    @IBOutlet weak var brightnessSlider: UISlider?
    @IBOutlet weak var brightnessNegativeLabel: StyledLabel?
    @IBOutlet weak var brightnessPositiveLabel: StyledLabel?
    
    @IBOutlet var rgbLedViews: [UIView]!
    
    let onString         = "ON"
    let offString        = "OFF"
    let colorString      = "COLOR"
    let brightnessString = "BRIGHTNESS"
    let switchesString   = "SWITCHES"
    let lightsString     = "LIGHTS"

    struct ButtonImageNames {
        static let Off      = "btn_io_light_off"
        static let Red      = "btn_io_light_red_on"
        static let Green    = "btn_io_light_green_on"
        static let Blue     = "btn_io_light_blue_on"
    }
    
    let switchOnImage  = "icn_io_switch_on"
    let switchOffImage = "icn_io_switch_off"

    var interaction: IoDemoInteraction?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        addSliderGestures()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tb_setNavigationBarStyleForDemo(.IO)
        interaction?.updateView()
    }
    
    //MARK: - Actions
    
    @IBAction func light1ButtonPressed(sender: UIButton) {
        self.interaction?.toggleLed(0)
    }
    
    @IBAction func light2ButtonPressed(sender: UIButton) {
        self.interaction?.toggleLed(1)
    }
    
    @IBAction func rgbLightButtonPressed(sender: UIButton) {
        interaction?.toggleLed(2)
    }
    
    @IBAction func colorSliderChanged(sender: UISlider) {
        guard let color = colorForSliderValues() else {
            return
        }
        
        interaction?.setColor(2, color: color)
    }
    
    @IBAction func brightnessSliderChanged(sender: UISlider) {
        guard let color = colorForSliderValues() else {
            return
        }
        
        interaction?.setColor(2, color: color)
    }
    
    //MARK: - IoDemoInteractionOutput
    
    func showButtonState(button: Int, pressed: Bool) {
        switch button {
        case 0:
            log.debug("Button 0 is \(pressed)")
            if (pressed) {
                switch1View.startAnimating()
            } else {
                switch1View.stopAnimating()
            }
            switch1OnOffLabel.text = pressed ? onString : offString
        case 1:
            log.debug("Button 1 is \(pressed)")
            if (pressed) {
                switch2View.startAnimating()
            } else {
                switch2View.stopAnimating()
            }
            switch2OnOffLabel.text = pressed ? onString : offString
        default:
            break
        }
    }
    
    func showLedState(led: Int, state: LedState) {
        
        switch state {
        case .Digital(let on, let color):
            showDigital(led, on: on, color: color)
        case .RGB(let on, let color):
            showRgbState(on, color: color)
        }
    }
    
    private func showDigital(index: Int, on: Bool, color: LedStaticColor? = nil) {
        log.debug("showLedState \(index) \(on)")

        let buttons: [UIButton] = [light1Button, light2Button, rgbButton!]
        let labels: [StyledLabel] = [light1OnOffLabel, light2OnOffLabel, rgbStateLabel!]
        
        let image: String = {
            if on {
                if let color = color {
                    switch color {
                    case .Red:
                        return ButtonImageNames.Red
                    case .Blue:
                        return ButtonImageNames.Blue
                    case .Green:
                        return ButtonImageNames.Green
                    }
                }
                
                return ButtonImageNames.Green
            }
            else {
                return ButtonImageNames.Off
            }
        }()
        
        buttons[index].setImage(UIImage(named: image)!, forState: .Normal)
        labels[index].text = on ? onString : offString
    }
    
    private func showRgbState(on: Bool, color: LedRgb) {
        showDigital(2, on: on)
        
        let color = color.uiColor
        var brightness: CGFloat = 0.0
        var hue: CGFloat = 0.0
        
        color.getHue(&hue, saturation: nil, brightness: &brightness, alpha: nil)
        
        brightnessSlider?.enabled = on
        brightnessSlider?.value = Float(brightness)
        
        colorSlider?.enabled = on
        colorSlider?.value = Float(hue)
        colorHueView?.hidden = !on
        let trackColor = on ? UIColor.clearColor() : StyleColor.lightGray
        colorSlider?.minimumTrackTintColor = trackColor
        colorSlider?.maximumTrackTintColor = trackColor
        

        // Instead of using brightness, we adjust opacity on the views to simulate brightness
        let imageColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: brightness)
        rgbLedViews.forEach({ $0.backgroundColor = on ? imageColor : StyleColor.gray })
    }
    
    func disableRgb() {
        rgbLightsView?.removeFromSuperview()
    }

    //MARK: - Internal
    
    private func colorForSliderValues() -> LedRgb? {
        guard let hue = colorSlider?.value,
            brightness = brightnessSlider?.value else {
                return nil
        }
        
        let color = UIColor(hue: CGFloat(hue), saturation: 1.0, brightness: CGFloat(brightness), alpha: 1.0)
        var r = CGFloat(0)
        var g = CGFloat(0)
        var b = CGFloat(0)
        
        color.getRed(&r, green: &g, blue: &b, alpha: nil)
        
        return LedRgb(red: Float(r), green: Float(g), blue: Float(b))
    }
    
    private func setupAppearance() {
        setupSwitchesSectionAppearance()
        setupLightsSectionAppearance()
        setupRgbSectionAppearance()
    }

    private func setupSwitchesSectionAppearance() {
        switchesLabel.tb_setText(switchesString, style: StyleText.header2)
        switchesView.backgroundColor = StyleColor.white
        switchesView.tb_applyCommonRoundedCornerWithShadowStyle()
        
        switch1OnOffLabel.style = StyleText.demoStatus
        switch2OnOffLabel.style = StyleText.demoStatus
    }
    
    private func setupLightsSectionAppearance() {
        lightsLabel.tb_setText(lightsString, style: StyleText.header2)
        lightsView.backgroundColor = StyleColor.white
        lightsView.tb_applyCommonRoundedCornerWithShadowStyle()
        
        light1OnOffLabel.style = StyleText.demoStatus
        light2OnOffLabel.style = StyleText.demoStatus
    }
    
    private func setupRgbSectionAppearance() {
        rgbLightsView?.backgroundColor = StyleColor.white
        rgbLightsView?.tb_applyCommonRoundedCornerWithShadowStyle()
        colorHueView?.tb_applyRoundedCorner(1)
        
        rgbButton?.setImage(UIImage(named: "ic_led_lights_off")!, forState: .Normal)
        rgbStateLabel?.style = StyleText.demoStatus
        rgbStateLabel?.text = "--"
        
        colorLabel?.tb_setText(colorString, style: .header2)
        colorSlider?.minimumTrackTintColor = UIColor.clearColor()
        colorSlider?.maximumTrackTintColor = UIColor.clearColor()
        colorSlider?.minimumValue = 0.01
        colorSlider?.maximumValue = 0.99
        colorSlider?.continuous = true
        
        brightnessLabel?.tb_setText(brightnessString, style: .header2)
        brightnessSlider?.minimumTrackTintColor = StyleColor.lightGray
        brightnessSlider?.maximumTrackTintColor = StyleColor.lightGray
        brightnessSlider?.minimumValue = 0.01
        brightnessSlider?.maximumValue = 1.00
        brightnessSlider?.continuous = true
        
        brightnessNegativeLabel?.tb_setText("-", style: StyleText.demoStatus)
        brightnessPositiveLabel?.tb_setText("+", style: StyleText.demoStatus)

        rgbLedViews.forEach({
            $0.backgroundColor = StyleColor.lightGray
            $0.tb_applyRoundedCorner(Float($0.frame.size.width/2))
        })
    }
    
    private func addSliderGestures() {
        brightnessSlider?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(brightnessSliderTapped)))
        colorSlider?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(colorSliderTapped)))
    }
    
    @objc func brightnessSliderTapped(recognizer: UITapGestureRecognizer) {
        brightnessSlider?.tb_updateSliderValueWithTap(recognizer)
    }
    
    @objc func colorSliderTapped(recognizer: UITapGestureRecognizer) {
        colorSlider?.tb_updateSliderValueWithTap(recognizer)
    }
}

extension LedRgb {
    var uiColor: UIColor {
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
}

extension UISlider {
    func tb_updateSliderValueWithTap(gesture: UITapGestureRecognizer) {
        let point = gesture.locationInView(self)
        self.value = Float(point.x / self.frame.size.width)
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
}

