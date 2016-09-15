//
//  CompleteProfileTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/14/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import GoogleSignIn

class CompleteProfileTableViewController: UITableViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
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
    
    lazy var linkedIn : UIButton = {
        let $ = UIButton()
        $.setTitle("Linked In", for: .normal)
        $.setTitleColor(Colors.brand, for: .normal)
        $.addTarget(self, action:#selector(prefill(sender:)), for:.touchUpInside)
        return $
    }()
    lazy var twitter : UIButton = {
        let $ = UIButton()
        $.setTitle("Twitter", for: .normal)
        $.setTitleColor(Colors.brand, for: .normal)
        $.addTarget(self, action:#selector(prefill(sender:)), for:.touchUpInside)
        return $
    }()
    lazy var google : UIButton = {
        let $ = UIButton()
        $.setTitle("Google", for: .normal)
        $.setTitleColor(Colors.brand, for: .normal)
        $.addTarget(self, action:#selector(prefill(sender:)), for:.touchUpInside)
        return $
    }()
    lazy var buttons : UIStackView = {
        let stack = UIStackView(arrangedSubviews:[self.linkedIn, self.twitter, self.google])
        stack.distribution = .fillEqually
        stack.spacing = 5
        stack.translates = false
        stack.constrain((.height, 35))
        return stack
    }()
    
    let firstName = SkyFloatingLabelTextField(translates: false).then {
        $0.placeholder = "First Name"
        $0.selectedTitleColor = Colors.brand
        $0.selectedLineColor = Colors.brand
    }
    let lastName = SkyFloatingLabelTextField(translates: false).then {
        $0.placeholder = "Last Name"
        $0.selectedTitleColor = Colors.brand
        $0.selectedLineColor = Colors.brand
    }
    let titleField = SkyFloatingLabelTextField(translates: false).then {
        $0.placeholder = "Job Title"
        $0.selectedTitleColor = Colors.brand
        $0.selectedLineColor = Colors.brand
    }
    let company = SkyFloatingLabelTextField(translates: false).then {
        $0.placeholder = "Company"
        $0.selectedTitleColor = Colors.brand
        $0.selectedLineColor = Colors.brand
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Complete Profile"
        
        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationItem.setHidesBackButton(true, animated: true)
        
        let tableHeader = UIView(translates: false)
        tableHeader.addSubviews(header, text)
        header.constrain(.top, constant: 20, toItem: tableHeader)
        header.constrain(.centerX, toItem: tableHeader)
        
        text.constrain(.top, toItem: header, toAttribute: .bottom)
        text.constrain(.centerX, toItem: tableHeader)
        text.constrain(.leading, constant: 20, toItem: tableHeader)
        text.constrain(.trailing, constant: -20, toItem: tableHeader)
        text.constrain(.bottom, constant: -25, toItem: tableHeader)
        
        tableView.tableHeaderView = tableHeader
        tableHeader.constrain(.centerX, .width, .top, toItem: view)
        tableHeader.layoutIfNeeded()
        tableView.tableHeaderView = tableHeader
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = section == 0 ? "    IMPORT YOUR PROFILE" : "    REQUIRED INFO"
        let label = UILabel()
        label.text = title
        label.font = .proxima(ofSize:12)
        label.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        label.contentMode = .top
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
        cell.selectionStyle = .none

        if indexPath.section == 0 {
            cell.addSubview(buttons)
            buttons.constrain(.width, toItem: cell)
        } else {
            var field : SkyFloatingLabelTextField? = nil
            switch indexPath.row {
            case 0:
                field = firstName
                cell.addSubview(firstName)
                break
            case 1:
                field = lastName
                cell.addSubview(lastName)
                break
            case 2:
                field = titleField
                cell.addSubview(titleField)
                break
            case 3:
                field = company
                cell.addSubview(company)
                break
            default: break
            }
            field?.constrain(.height, constant: -10, toItem: cell)
            field?.constrain(.leading, constant: 15, toItem: cell)
            field?.constrain(.trailing, constant: -15, toItem: cell)
        }
        return cell
    }
    
    func prefill(sender: UIButton) {
        if sender == twitter{
            TwitterProfile.prefill() { response in
                self.fill(response)
            }
        }
        if sender == google {
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            GoogleProfile.prefill()
        }
        if sender == linkedIn {
            LinkedInProfile.prefill() { response in
                self.fill(response)
            }
        }
    }

    func fill(_ prefill: PrefillResponse) {
        firstName.text = prefill.first_name
        lastName.text = prefill.last_name
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
//            let userId = user.userID                  // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let fullName = user.profile.name
            let givenName = user.profile.givenName ?? ""
            let familyName = user.profile.familyName ?? ""
            let email = user.profile.email ?? ""
            let imageURL = user.profile.imageURL(withDimension: 2000)?.absoluteString ?? ""
            
            fill((givenName, familyName, email, imageURL))
        } else {
            print("\(error.localizedDescription)")
        }
    }

}
