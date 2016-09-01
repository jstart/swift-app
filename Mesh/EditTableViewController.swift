//
//  EditTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/1/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EditTableViewController: UITableViewController, UITextFieldDelegate {

    var first_name : UITextField?
    var last_name : UITextField?
    var email : UITextField?
    var titleField : UITextField?
    var profession : UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
    }
    
    func save() {
        let first_name = self.first_name?.text ?? ""
        let last_name = self.last_name?.text ?? ""
        let email = self.email?.text ?? ""
        let title = self.titleField?.text ?? ""
        let profession = self.profession?.text ?? ""
        
        let companies = [CompanyModel(id: "tinder", start_month: "January", start_year: "2014", end_month: "March", end_year: "2016", current: false)]
        Client().execute(ProfileRequest(first_name: first_name, last_name: last_name, email: email, title: title, profession: profession, companies: companies), completionHandler: { response in
            
        })
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "first_name"
        case 1:
            return "last_name"
        case 2:
            return "email"
        case 3:
            return "title"
        case 4:
            return "profession"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.selectionStyle = .none
        let field = UITextField()
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        cell.addSubview(field)
        field.constrain(.leadingMargin, .trailing, .height, .centerY, toItem: cell)
        
        switch indexPath.section {
        case 0:
            field.text = UserResponse.currentUser?.first_name ?? ""
            first_name = field
            break
        case 1:
            field.text = UserResponse.currentUser?.last_name ?? ""
            last_name = field
            break
        case 2:
            email = field
            break
        case 3:
            field.text = UserResponse.currentUser?.title ?? ""
            titleField = field
            break
        case 4:
            field.text = UserResponse.currentUser?.profession ?? ""
            profession = field
            break
        default:
            break
        }
        return cell
    }
 
}
