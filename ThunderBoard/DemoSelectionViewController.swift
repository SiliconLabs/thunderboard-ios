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
            self.tableView?.backgroundColor = UIColor.clear
        }
    }
    
    var interaction: DemoSelectionInteraction?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StyleColor.lightGray
        self.tableView?.backgroundColor = UIColor.clear
        self.title = "Thunderboard"
        self.tb_removeTitleFromBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tb_setNavigationBarStyleForDemo(.demoSelection)
        
        // (roughly) center the table view content in the view
        guard let table = self.tableView else {
            return
        }
        
        let available = self.view.frame.size.height - (64 * 2)
        let content = tableView(table, heightForRowAt: IndexPath(row: 0, section: 0)) * CGFloat(tableView(table, numberOfRowsInSection: 0))
        let inset = (available - content) / 2
        
        table.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: 0, right: 0)
        table.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    fileprivate func configureCell(_ cell: DemoTableViewCell, demo: ThunderboardDemo) {
        switch(demo) {
        case .io:
            cell.demoName.tb_setText("I/O", style: StyleText.demoTitle)
            cell.demoImage.image = UIImage(named: "icn_demo_io_unsel")

        case .motion:
            cell.demoName.tb_setText("Motion", style: StyleText.demoTitle)
            cell.demoImage.image = UIImage(named: "icn_demo_motion_unsel")
            
        case .environment:
            cell.demoName.tb_setText("Environment", style: StyleText.demoTitle)
            cell.demoImage.image = UIImage(named: "icn_demo_environmental_unsel")
        }
        
        cell.demoSpinner.lineColor = StyleColor.terbiumGreen
        cell.demoSpinner.trackColor = StyleColor.lightGray
        
        cell.accessoryType = .none
        cell.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = StyleColor.mediumGreen
        
        let configuring = (demo == self.interaction?.configuringDemo)
        (configuring) ? cell.demoSpinner.startAnimating(StyleAnimations.spinnerDuration) : cell.demoSpinner.stopAnimating()
    }

    //MARK:- UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "demoCell") as! DemoTableViewCell
        configureCell(cell, demo: ThunderboardDemo(rawValue: indexPath.row)!)
        return cell
    }
    
    //MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let demo = ThunderboardDemo(rawValue: indexPath.row)!
        interaction?.configureForDemo(demo)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 98
    }
    
    //MARK:- DemoSelectionInteractionOutput
    
    func showConfiguringDemo(_ demo: ThunderboardDemo) {
        self.tableView?.reloadData()
    }
    
    func enableDemoHistory(_ enabled: Bool) {
        self.historyButton?.isEnabled = enabled
    }
}

