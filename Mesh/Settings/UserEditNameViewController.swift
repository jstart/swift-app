//
//  UserEditNameViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class UserEditNameViewController: UITableViewController {
    
    let header = UILabel(translates: false).then {
        $0.text = "Change Your Name"; $0.font = .gothamBold(ofSize: 20)
    }
    let text = UILabel(translates: false).then {
        $0.numberOfLines = 0
        $0.text = "Change the name that appears on your profile."
        $0.font = .gothamBook(ofSize: 16); $0.textColor = .gray
        $0.textAlignment = .center
    }
    let nextButton = UIButton(translates: false).then {
        $0.setBackgroundImage(.imageWithColor(Colors.brand), for: .normal)
        $0.setBackgroundImage(.imageWithColor(.lightGray), for: .disabled)
        $0.isEnabled = true
        $0.titleLabel?.font = .gothamBold(ofSize: 20)
        $0.title = "CONTINUE"; $0.titleColor = .white
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.constrain((.height, 70))
    }
    let firstName = SkyFloatingLabelTextField.branded("First Name")
    let lastName = SkyFloatingLabelTextField.branded("Last Name")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Change Name"
        
        view.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.backgroundColor = .white
        
        firstName.text = UserResponse.current?.first_name
        lastName.text = UserResponse.current?.last_name
        
        let inputView = UIView(translates: false)
        inputView.addSubview(nextButton)
        nextButton.constrain((.centerX, 0), (.bottom, -20), toItem: inputView)
        nextButton.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: inputView, toAttribute: .leadingMargin)
        nextButton.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: inputView, toAttribute: .trailingMargin)
        
        UITextField.connectFields(fields: [firstName, lastName])

        [firstName, lastName].forEach({
            $0.addTarget(self, action: #selector(fieldEdited), for: .allEditingEvents)
            $0.inputAccessoryView = inputView
        })
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
        let _ = firstName.becomeFirstResponder()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 3 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
        cell.selectionStyle = .none
        
        var field : SkyFloatingLabelTextField? = nil
        switch indexPath.row {
        case 0: field = firstName; cell.addSubview(firstName); break
        case 1: field = lastName; cell.addSubview(lastName); break
        default: break }
        field?.constrain((.height, -10), (.leading, 15), (.trailing, -15), toItem: cell)
        return cell
    }
    
    func fieldEdited() { nextButton.superview?.superview?.constraintFor(.height)?.constant = 90; nextButton.isEnabled = (firstName.text != "" && lastName.text != "") }
    
    func complete() {
        let request = ProfileRequest(first_name: firstName.text, last_name: lastName.text)
        Client.execute(request) { _ in self.navigationController?.pop() }
    }

}
