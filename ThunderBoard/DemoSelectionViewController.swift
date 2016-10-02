//
//  DemoSelectionViewController.swift
//  Thunderboard
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
        self.view.backgroundColor = StyleColor.lightGray
        self.tableView?.backgroundColor = UIColor.clearColor()
        self.title = "Thunderboard"
        self.tb_removeTitleFromBackButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tb_setNavigationBarStyleForDemo(.DemoSelection)
        
        // (roughly) center the table view content in the view
        guard let table = self.tableView else {
            return
        }
        
        let available = self.view.frame.size.height - (64 * 2)
        let content = tableView(table, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) * CGFloat(tableView(table, numberOfRowsInSection: 0))
        let inset = (available - content) / 2
        
        table.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: 0, right: 0)
        table.reloadData()
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
    
    private func configureCell(cell: DemoTableViewCell, demo: ThunderboardDemo) {
        switch(demo) {
        case .IO:
            cell.demoName.tb_setText("I/O", style: StyleText.demoTitle)
            cell.demoImage.image = UIImage(named: "icn_demo_io_unsel")

        case .Motion:
            cell.demoName.tb_setText("Motion", style: StyleText.demoTitle)
            cell.demoImage.image = UIImage(named: "icn_demo_motion_unsel")
            
        case .Environment:
            cell.demoName.tb_setText("Environment", style: StyleText.demoTitle)
            cell.demoImage.image = UIImage(named: "icn_demo_environmental_unsel")
        }
        
        cell.demoSpinner.lineColor = StyleColor.terbiumGreen
        cell.demoSpinner.trackColor = StyleColor.lightGray
        
        cell.accessoryType = .None
        cell.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = StyleColor.mediumGreen
        
        let configuring = (demo == self.interaction?.configuringDemo)
        (configuring) ? cell.demoSpinner.startAnimating(StyleAnimations.spinnerDuration) : cell.demoSpinner.stopAnimating()
    }

    //MARK:- UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("demoCell") as! DemoTableViewCell
        configureCell(cell, demo: ThunderboardDemo(rawValue: indexPath.row)!)
        return cell
    }
    
    //MARK:- UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let demo = ThunderboardDemo(rawValue: indexPath.row)!
        interaction?.configureForDemo(demo)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 98
    }
    
    //MARK:- DemoSelectionInteractionOutput
    
    func showConfiguringDemo(demo: ThunderboardDemo) {
        self.tableView?.reloadData()
    }
    
    func enableDemoHistory(enabled: Bool) {
        self.historyButton?.enabled = enabled
    }
}

