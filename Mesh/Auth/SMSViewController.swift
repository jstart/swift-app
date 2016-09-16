//
//  SMSViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SMSViewController: UITableViewController, UITextFieldDelegate {
    
    var formatter = PhoneNumberFormatter()
    
    let logo = UIImageView(image: #imageLiteral(resourceName: "logo")).then {
        $0.translates = false
    }
    let subtitle = UILabel(translates: false).then {
        $0.text = "Tinder for Business"
        $0.textColor = .black
        $0.font = .boldProxima(ofSize: 20)
    }
    let nextButton = UIButton(translates: false).then {
        $0.setBackgroundImage(.imageWithColor(Colors.brand), for: .normal)
        $0.setBackgroundImage(.imageWithColor(.lightGray), for: .disabled)
        $0.isEnabled = true
        $0.titleLabel?.font = .boldProxima(ofSize: 20)
        $0.setTitle("CONTINUE", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.constrain((.height, 70))
    }
    
    let phone = SkyFloatingLabelTextField.branded("Phone Number").then {
        $0.keyboardType = .phonePad
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
    }
    let password = SkyFloatingLabelTextField.branded("Password").then {
        $0.isSecureTextEntry = true
    }
    let confirmPassword = SkyFloatingLabelTextField.branded("Confirm Password").then {
        $0.isSecureTextEntry = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Complete Profile"
        
        view.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.backgroundColor = .white
        
        phone.addTarget(self, action: #selector(format), for: .allEditingEvents)
        
        let inputView = UIView(translates: false)
        inputView.addSubview(nextButton)
        nextButton.constrain((.centerX, 0), (.bottom, -20), (.height, 0), toItem: inputView)
        nextButton.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: inputView, toAttribute: .leadingMargin)
        nextButton.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: inputView, toAttribute: .trailingMargin)
        
        [phone, password, confirmPassword].forEach({
            $0.delegate = self
            $0.addTarget(self, action: #selector(fieldEdited), for: .allEditingEvents)
            $0.inputAccessoryView = inputView
        })
        nextButton.addTarget(self, action: #selector(complete), for: .touchUpInside)
        
        
        let tableHeader = UIView(translates: false)
        tableHeader.addSubviews(logo, subtitle)
        logo.constrain((.top, 20), (.centerX, 0), toItem: tableHeader)
        
        subtitle.constrain(.top, toItem: logo, toAttribute: .bottom)
        subtitle.constrain((.leading, 20), (.trailing, -20), (.bottom, -25), (.centerX, 0), toItem: tableHeader)
        
        tableView.tableHeaderView = tableHeader
        tableHeader.constrain(.centerX, toItem: tableView)
        
        tableHeader.layoutIfNeeded()
        tableView.tableHeaderView = tableHeader
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        nextButton.superview?.superview?.constraintFor(.height).constant = 70
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.setNavigationBarHidden(true, animated: true)
       
        let _ = phone.becomeFirstResponder()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 3 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
        cell.selectionStyle = .none
        
        var field : SkyFloatingLabelTextField? = nil
        switch indexPath.row {
        case 0: field = phone; cell.addSubview(phone); break
        case 1: field = password; cell.addSubview(password); break
        case 2: field = confirmPassword; cell.addSubview(confirmPassword); break
        default: break
        }
        field?.constrain((.height, -10), (.leading, 15), (.trailing, -15), toItem: cell)
        return cell
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nextButton.superview?.superview?.constraintFor(.height).constant = 70
        nextButton.superview?.superview?.layoutIfNeeded()
    }
    
    func format() { phone.text = formatter.format(phone.text!) }
    
    func fieldEdited() { nextButton.isEnabled = (phone.text != "" && password.text != "" && confirmPassword.text != "") }
    
    func complete() { navigationController?.push(SMSVerifyViewController()) }

}
