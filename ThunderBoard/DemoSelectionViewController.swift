//
//  DemoSelectionViewController.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class DemoSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DemoSelectionInteractionOutput {

    @IBOutlet var historyButton: UIBarButtonItem?
    @IBOutlet var tableView: UITableView? {
        didSet {
            self.tableView?.backgroundColor = UIColor.clearColor()
        }
    }
    
    var interaction: DemoSelectionInteraction?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StyleColor.siliconGray
        self.tableView?.backgroundColor = UIColor.clearColor()
        self.title = ""
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tb_setNavigationBarStyleForDemo(.Transparent)
        self.tableView?.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        interaction?.resetDemoConfiguration()
    }

    @IBAction func historyButtonPressed() {
        interaction?.showHistory()
    }
    
    @IBAction func settingsButtonPressed() {
        interaction?.showSettings()
    }
    
    //MARK:- Internal
    
    private func configureCell(cell: DemoTableViewCell, demo: ThunderBoardDemo) {
        switch(demo) {
        case .IO:
            cell.demoName.tb_setText("I/O", style: StyleText.demoTitle)
            cell.demoImage.image = UIImage(named: "icn_demo_io_unsel")
            cell.demoSpinner.lineColor = StyleColor.gold

        case .Motion:
            cell.demoName.tb_setText("Motion", style: StyleText.demoTitle)
            cell.demoImage.image = UIImage(named: "icn_demo_motion_unsel")
            cell.demoSpinner.lineColor = StyleColor.redOrange
            
        case .Environment:
            cell.demoName.tb_setText("Environment", style: StyleText.demoTitle)
            cell.demoImage.image = UIImage(named: "icn_demo_environmental_unsel")
            cell.demoSpinner.lineColor = StyleColor.mediumGreen
        }
        
        cell.accessoryType = .None
        cell.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = StyleColor.footerGray
        
        cell.demoSpinner.trackColor = StyleColor.footerGray
        
        let configuring = (demo == self.interaction?.configuringDemo)
        (configuring) ? cell.demoSpinner.startAnimating(StyleAnimations.spinnerDuration) : cell.demoSpinner.stopAnimating()
    }

    //MARK:- UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("demoCell") as! DemoTableViewCell
        configureCell(cell, demo: ThunderBoardDemo(rawValue: indexPath.row)!)
        return cell
    }
    
    //MARK:- UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let demo = ThunderBoardDemo(rawValue: indexPath.row)!
        interaction?.configureForDemo(demo)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 98
    }
    
    //MARK:- DemoSelectionInteractionOutput
    
    func showConfiguringDemo(demo: ThunderBoardDemo) {
        self.tableView?.reloadData()
    }
    
    func enableDemoHistory(enabled: Bool) {
        self.historyButton?.enabled = enabled
    }
}

