//
//  IODemoViewController.swift
//  ThunderBoard
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
    
    let onString         = "ON"
    let offString        = "OFF"
    let switchesString   = "SWITCHES"

    let switchOnImage  = "icn_io_switch_on"
    let switchOffImage = "icn_io_switch_off"
    let light1OnImage  = "btn_io_light_blue_on"
    let light2OnImage  = "btn_io_light_green_on"
    let lightOffImage  = "btn_io_light_off"

    var interaction: IoDemoInteraction?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupLayout()
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
    
    //MARK: - IoDemoInteractionOutput
    
    func showButtonState(button: Int, pressed: Bool) {
        assert(NSThread.isMainThread() == true)
        if(button == 0) {
            log.debug("Button 0 is \(pressed)")
            if (pressed) {
                switch1View.startAnimating()
            } else {
                switch1View.stopAnimating()
            }
            switch1OnOffLabel.text = pressed ? onString : offString
        } else {
            log.debug("Button 1 is \(pressed)")
            if (pressed) {
                switch2View.startAnimating()
            } else {
                switch2View.stopAnimating()
            }
            switch2OnOffLabel.text = pressed ? onString : offString
        }
    }
    
    func showLedState(led: UInt, isOn: Bool) {
        log.debug("showLedState \(led) \(isOn)")
        if led == 0 {
            let image1 = isOn ? light1OnImage : lightOffImage
            light1Button.setImage(UIImage(named: image1), forState: .Normal)
            light1OnOffLabel.text = isOn ? onString : offString
        } else if led == 1 {
            let image2 = isOn ? light2OnImage : lightOffImage
            light2Button.setImage(UIImage(named: image2), forState: .Normal)
            light2OnOffLabel.text = isOn ? onString : offString
        }
    }

    //MARK: - Internal
    
    private func setupAppearance() {
        setupSwitchesSectionAppearance()
        setupLightsSectionAppearance()
    }
    
    private func setupLayout() {
        let constraint = NSLayoutConstraint(
            item: self.contentView!,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.lightsView,
            attribute: .Bottom,
            multiplier: 1,
            constant: 10)
        
        self.view.addConstraint(constraint)
    }

    private func setupSwitchesSectionAppearance() {
        switchesLabel.tb_setText(switchesString, style: StyleText.header2)
        switchesView.backgroundColor = StyleColor.mediumGray
        switchesView.tb_applyCommonRoundedCornerWithShadowStyle()
        
        switch1OnOffLabel.style = StyleText.demoStatus
        switch2OnOffLabel.style = StyleText.demoStatus
    }
    
    private func setupLightsSectionAppearance() {
        lightsLabel.tb_setText("LIGHTS", style: StyleText.header)
        lightsView.backgroundColor = StyleColor.mediumGray
        lightsView.tb_applyCommonRoundedCornerWithShadowStyle()
        
        light1OnOffLabel.style = StyleText.demoStatus
        light2OnOffLabel.style = StyleText.demoStatus
    }
}
