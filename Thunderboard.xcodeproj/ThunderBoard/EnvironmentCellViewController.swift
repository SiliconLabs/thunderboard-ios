//
//  EnvironmentCellViewController.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class EnvironmentCellViewController: UIViewController {

    @IBOutlet weak var backgroundTileView: UIView?
    @IBOutlet weak var titleLabel: StyledLabel?
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var valueLabel: StyledLabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundTileView?.backgroundColor = StyleColor.mediumGray
        self.backgroundTileView?.tb_applyCommonRoundedCornerWithShadowStyle()

        self.titleLabel?.style = StyleText.header2
        self.titleLabel?.text = ""
        
        self.valueLabel?.style = StyleText.demoStatus
        self.valueLabel?.text = ""
    }
    
    override var nibName: String? {
        get { return "EnvironmentCellViewController" }
    }
}

class EnvironmentCellView : UIView {
    
}