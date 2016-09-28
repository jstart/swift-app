//
//  UserEditEmailViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class UserEditEmailViewController: UITableViewController {
    
    let header = UILabel(translates: false).then {
        $0.text = "Add Your Email"
        $0.font = .boldProxima(ofSize: 20)
    }
    let text = UILabel(translates: false).then {
        $0.numberOfLines = 0
        $0.text = "Adding an email will keep your account more secure."
        $0.font = .proxima(ofSize: 16)
        $0.textColor = .gray
        $0.textAlignment = .center
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
    let email = SkyFloatingLabelTextField.branded("Email").then {
        $0.keyboardType = .emailAddress
        $0.autocapitalizationType = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Email"
        
        view.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.backgroundColor = .white
        
        email.text = UserResponse.current?.email
        
        let inputView = UIView(translates: false)
        inputView.addSubview(nextButton)
        nextButton.constrain((.centerX, 0), (.bottom, -20), toItem: inputView)
        nextButton.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: inputView, toAttribute: .leadingMargin)
        nextButton.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: inputView, toAttribute: .trailingMargin)
        
        email.addTarget(self, action: #selector(fieldEdited), for: .allEditingEvents)
        email.inputAccessoryView = inputView

        nextButton.addTarget(self, action: #selector(complete), for: .touchUpInside)
        
        let tableHeader = UIView(translates: false)
        tableHeader.addSubviews(header, text)
        header.constrain((.top, 20), (.centerX, 0), toItem: tableHeader)
        
        text.constrain(.top, toItem: header, toAttribute: .bottom)
        text.constrain((.leading, 20), (.trailing, -20), (.bottom, -25), (.centerX, 0), toItem: tableHeader)
        
        tableView.tableHeaderView = tableHeader
        tableHeader.constrain(.centerX, .width, .top, toItem: view)
        tableHeader.layoutIfNeeded()
        tableView.tableHeaderView = tableHeader
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let _ = email.becomeFirstResponder()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
        cell.selectionStyle = .none
        
        var field : SkyFloatingLabelTextField? = nil
        switch indexPath.row {
        case 0: field = email; cell.addSubview(email); break
        default: break
        }
        field?.constrain((.height, -10), (.leading, 15), (.trailing, -15), toItem: cell)
        return cell
    }
    
    func fieldEdited() { nextButton.superview?.superview?.constraintFor(.height).constant = 90; nextButton.isEnabled = (email.text != "") }
    
    func complete() {
        let request = ProfileRequest(email: email.text)
        Client.execute(request) { _ in
            self.navigationController?.pop()
        }
    }

}
