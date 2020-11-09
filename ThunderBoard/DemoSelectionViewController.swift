//
//  DemoSelectionViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class DemoSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DemoSelectionInteractionOutput {

    @IBOutlet var historyButton: UIBarButtonItem?
    
    var interaction: DemoSelectionInteraction?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StyleColor.lightGray
        self.navigationController!.navigationItem.backBarButtonItem?.title = "Previous"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.title = ""
        for cell: UICollectionViewCell in self.collectionView.visibleCells {
            if let cell: DashboardCollectionViewCell = cell as? DashboardCollectionViewCell {
                cell.demoSpinner.stopAnimating()
                cell.demoSpinner.isHidden = true
            }
        }
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
    
    fileprivate func configureCell(_ cell: DashboardCollectionViewCell, demo: ThunderboardDemo) {
        switch(demo) {
        case .io:
            cell.titleLabel.text = NSLocalizedString("io", comment: "")
            cell.icon.image = UIImage(named: "icon - power")
            // TODO: ask client for info about detailLabel content
            cell.detailsLabel.text = "Button and LED control."
        case .motion:
            cell.titleLabel.text = NSLocalizedString("motion", comment: "")
            cell.icon.image = UIImage(named: "icon - motion")
            // TODO: ask client for info about detailLabel content
            cell.detailsLabel.text = "Control a 3D rendering of the physical board."
        case .environment:
            cell.titleLabel.text = NSLocalizedString("environment", comment: "")
            cell.icon.image = UIImage(named: "icon - environment")
            // TODO: ask client for info about detailLabel content
            cell.detailsLabel.text = "Read and display data from the board sensors."
        }
    }

    //MARK:- UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DashboardCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCollectionViewCell", for: indexPath) as! DashboardCollectionViewCell
        configureCell(cell, demo: ThunderboardDemo(rawValue: indexPath.row)!)
        return cell
    }
    
    //MARK:- UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        DispatchQueue.main.async {
            let demo = ThunderboardDemo(rawValue: indexPath.row)!
            self.interaction?.configureForDemo(demo)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let cell: DashboardCollectionViewCell = collectionView.cellForItem(at: indexPath) as? DashboardCollectionViewCell {
                cell.demoSpinner.isHidden = false
                cell.demoSpinner.startAnimating()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
           layout collectionViewLayout: UICollectionViewLayout,
           sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.twoItemsInRowSize
    }
    
    //MARK:- DemoSelectionInteractionOutput
    
    func showConfiguringDemo(_ demo: ThunderboardDemo) {
        self.collectionView?.reloadData()
    }
    
    func enableDemoHistory(_ enabled: Bool) {
        self.historyButton?.isEnabled = enabled
    }
}

extension UICollectionView {
    var twoItemsInRowSize: CGSize {
        let cellsInRow: CGFloat = 2
        let height: CGFloat = 162
        let width: CGFloat = floor((self.frame.size.width - 64) / cellsInRow )
        let size: CGSize = CGSize(width: width, height: height)
        return size
    }
}
