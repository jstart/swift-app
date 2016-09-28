//
//  CompleteProfileTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/14/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import GoogleSignIn

extension SkyFloatingLabelTextField {
    static func branded(_ title: String) -> SkyFloatingLabelTextField {
        return SkyFloatingLabelTextField(translates: false).then {
            $0.placeholder = title
            $0.titleLabel.font = .proxima(ofSize: 10)
            $0.placeholderFont = .proxima(ofSize: 20)
            $0.selectedTitleColor = Colors.brand; $0.selectedLineColor = Colors.brand
            $0.titleFormatter = { string in return string }
        }
    }
}

class CompleteProfileTableViewController: UITableViewController, GIDSignInUIDelegate {
    
    let header = UILabel(translates: false).then {
        $0.text = "Add Your Basic Info"
        $0.font = .boldProxima(ofSize: 20)
    }
    let text = UILabel(translates: false).then {
        $0.numberOfLines = 0
        $0.text = "In order to match with people on Mesh, we need you to complete your profile."
        $0.font = .proxima(ofSize: 16)
        $0.textColor = .gray
        $0.textAlignment = .center
    }
    let linkedIn = UIButton().then { $0.title = "Linked In"; $0.titleColor = Colors.brand }
    let twitter = UIButton().then { $0.title = "Twitter"; $0.titleColor = Colors.brand }
    let google = UIButton().then { $0.title = "Google"; $0.titleColor = Colors.brand }
    lazy var buttons : UIStackView = {
        let stack = UIStackView(self.linkedIn, self.twitter, self.google, spacing: 5)
        stack.distribution = .fillEqually
        stack.translates = false
        stack.constrain((.height, 35))
        return stack
    }()
    let nextButton = UIButton(translates: false).then {
        $0.setBackgroundImage(.imageWithColor(Colors.brand), for: .normal)
        $0.setBackgroundImage(.imageWithColor(.lightGray), for: .disabled)
        $0.isEnabled = true
        $0.titleLabel?.font = .boldProxima(ofSize: 20)
        $0.setTitle("NEXT", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.constrain((.height, 70))
    }
    
    let firstName = SkyFloatingLabelTextField.branded("First Name"), lastName = SkyFloatingLabelTextField.branded("Last Name"),
    titleField = SkyFloatingLabelTextField.branded("Job Title"), company = SkyFloatingLabelTextField.branded("Company")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Complete Profile"

        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.backgroundColor = .white
        
        UITextField.connectFields(fields: [firstName, lastName, titleField, company])
        [firstName, lastName, titleField, company].forEach({$0.addTarget(self, action: #selector(fieldEdited), for: .allEditingEvents)})
        [linkedIn, twitter, google].forEach({$0.addTarget(self, action:#selector(prefill(sender:)), for:.touchUpInside)})
        nextButton.addTarget(self, action: #selector(complete), for: .touchUpInside)
        view.addSubview(nextButton)
        
        nextButton.constrain(.centerX, toItem: view)
        nextButton.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .leadingMargin)
        nextButton.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .trailingMargin)
        nextButton.constrain(.bottom, constant: view.frame.size.height - 65, toItem: view, toAttribute: .top)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationItem.setHidesBackButton(true, animated: true)
        
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
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = section == 0 ? "    IMPORT YOUR PROFILE" : "    REQUIRED INFO"
        return UILabel().then {
            $0.text = title
            $0.font = .proxima(ofSize:12)
            $0.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
            $0.contentMode = .top
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 25 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return section == 0 ? 1 : 4 }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
        cell.selectionStyle = .none

        if indexPath.section == 0 {
            cell.addSubview(buttons)
            buttons.constrain(.width, toItem: cell)
        } else {
            var field : SkyFloatingLabelTextField? = nil
            switch indexPath.row {
            case 0: field = firstName; cell.addSubview(firstName); break
            case 1: field = lastName; cell.addSubview(lastName); break
            case 2: field = titleField; cell.addSubview(titleField); break
            case 3: field = company; cell.addSubview(company); break
            default: break }
            field?.constrain((.height, -10), (.leading, 15), (.trailing, -15), toItem: cell)
        }
        return cell
    }
    
    func prefill(sender: UIButton) {
        if sender == twitter { TwitterProfile.prefill() { response in self.fill(response) } }
        if sender == google {
            GIDSignIn.sharedInstance().uiDelegate = self
            GoogleProfile.shared.prefill() { response in self.fill(response) }
        }
        if sender == linkedIn { LinkedInProfile.prefill() { response in self.fill(response) } }
    }

    func fill(_ prefill: PrefillResponse) {
        if prefill.first_name != "" { firstName.text = prefill.first_name }
        if prefill.last_name != "" { lastName.text = prefill.last_name }
        if prefill.title != "" { titleField.text = prefill.title }
        if prefill.company != "" { company.text = prefill.company }
        fieldEdited()
    }
    
    func fieldEdited() { nextButton.isEnabled = (firstName.text != "" && lastName.text != "" && titleField.text != "" && company.text != "") }
    
    func complete() {
        let companies = [CompanyModel(id: "1681681", start_month: "January", start_year: "2014", end_month: "March", end_year: "2016", current: false)]
        Client.execute(ProfileRequest(first_name: firstName.text, last_name: lastName.text, email: nil, title: titleField.text, profession: nil, companies: companies), complete: { _ in
            self.navigationController?.push(AddPhotoViewController())
        })
    }

}
