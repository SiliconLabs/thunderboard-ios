//
//  PersonalInfoViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class PersonalInfoViewController: UITableViewController {

    @IBOutlet weak var nameLabel:  StyledLabel!
    @IBOutlet weak var titleLabel: StyledLabel!
    @IBOutlet weak var emailLabel: StyledLabel!
    @IBOutlet weak var phoneLabel: StyledLabel!
    
    @IBOutlet weak var nameTextField:   UITextField!
    @IBOutlet weak var titleTextField:  UITextField!
    @IBOutlet weak var phoneTextField:  UITextField!
    @IBOutlet weak var emailTextField:  UITextField!
    
    fileprivate let nameText  = "NAME"
    fileprivate let titleText = "TITLE"
    fileprivate let emailText = "EMAIL"
    fileprivate let phoneText = "PHONE"
    
    fileprivate let settings = ThunderboardSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupNavButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        populateInputFields()
    }
    
    func populateInputFields() {
        self.nameTextField.text  = settings.userName
        self.titleTextField.text = settings.userTitle
        self.phoneTextField.text = settings.userPhone
        self.emailTextField.text = settings.userEmail
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let infoCell = cell as? PersonalInfoTableCell else {
            fatalError("invalid cell class")
        }
        
        infoCell.backgroundColor = StyleColor.white
        infoCell.drawSeparator = !tableView.tb_isFirstCell(indexPath)
        
        if tableView.tb_isLastCell(indexPath) {
            infoCell.tb_applyCommonDropShadow()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 15
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UITableViewHeaderFooterView()
        headerView.contentView.backgroundColor = StyleColor.siliconGray
        return headerView
    }
    
    func setupAppearance() {
        automaticallyAdjustsScrollViewInsets = true
        view.backgroundColor = StyleColor.lightGray
        tableView?.backgroundColor = StyleColor.lightGray
        
        nameLabel.tb_setText(nameText,   style: StyleText.subtitle2)
        nameTextField.textColor = StyleText.main1.color
        nameTextField.attributedPlaceholder = StyleText.main1.tweakColorAlpha(0.5).attributedString("Name")
        
        titleLabel.tb_setText(titleText, style: StyleText.subtitle2)
        titleTextField.textColor = StyleText.main1.color
        titleTextField.attributedPlaceholder = StyleText.main1.tweakColorAlpha(0.5).attributedString("Title")
        
        emailLabel.tb_setText(emailText, style: StyleText.subtitle2)
        emailTextField.textColor = StyleText.main1.color
        emailTextField.attributedPlaceholder = StyleText.main1.tweakColorAlpha(0.5).attributedString("Email")
        
        phoneLabel.tb_setText(phoneText, style: StyleText.subtitle2)
        phoneTextField.textColor = StyleText.main1.color
        phoneTextField.attributedPlaceholder = StyleText.main1.tweakColorAlpha(0.5).attributedString("###-###-####")
    }
    
    func setupNavButtons() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_navbar_close"), style: UIBarButtonItemStyle.done, target: self, action: #selector(handleCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_navbar_done_active"), style: UIBarButtonItemStyle.done, target: self, action: #selector(handleSave))
    }
    
    //MARK: Action Handlers
    func handleCancel() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func handleSave() {
        settings.userName      = self.nameTextField.text
        settings.userTitle     = self.titleTextField.text
        settings.userPhone     = self.phoneTextField.text
        settings.userEmail     = self.emailTextField.text
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
}
