//
//  EditTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/1/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EditTableViewController: UITableViewController, UITextFieldDelegate {

    var phone : UITextField?
    var first_name : UITextField?
    var last_name : UITextField?
    var email : UITextField?
    var titleField : UITextField?
    var profession : UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
    }
    
    func save() {
        //let phone_number = self.phone?.text ?? ""
        let first_name = self.first_name?.text ?? ""
        let last_name = self.last_name?.text ?? ""
        let email = self.email?.text ?? ""
        let title = self.titleField?.text ?? ""
        let profession = self.profession?.text ?? ""
        
        let companies = [CompanyModel(id: "tinder", start_month: "January", start_year: "2014", end_month: "March", end_year: "2016", current: false)]
        Client.execute(ProfileRequest(first_name: first_name, last_name: last_name, email: email, title: title, profession: profession, companies: companies), completionHandler: { response in
            if response.result.value != nil {
                let alert = UIAlertController(title: "Profile Updated", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction("OK", style: .cancel){ _ in self.navigationController?.pop() })
                self.present(alert)
            }
            else {
                let alert = UIAlertController(title: "Error", message: response.result.error?.localizedDescription ?? "Unknown Error", preferredStyle: .alert)
                alert.addAction(UIAlertAction("OK", style: .cancel))
                self.present(alert)
            }
        })
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 6 }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "phone"
        case 1: return "first_name"
        case 2: return "last_name"
        case 3: return "email"
        case 4: return "title"
        case 5: return "profession"
        default: return ""
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
        cell.selectionStyle = .none
        let field = UITextField(translates: false).then {
            $0.autocapitalizationType = .none
            $0.delegate = self
        }
        cell.addSubview(field)

        field.constrain(.leadingMargin, .trailing, .height, .centerY, toItem: cell)
        
        switch indexPath.section {
        case 0:
            field.text = UserResponse.current?.phone_number ?? ""
            field.isUserInteractionEnabled = false
            cell.backgroundColor = .lightGray
            phone = field; break
        case 1:
            field.text = UserResponse.current?.first_name ?? ""
            first_name = field; break
        case 2:
            field.text = UserResponse.current?.last_name ?? ""
            last_name = field; break
        case 3:
            field.text = UserResponse.current?.email ?? ""
            email = field; break
        case 4:
            field.text = UserResponse.current?.title ?? ""
            titleField = field; break
        case 5:
            field.text = UserResponse.current?.profession ?? ""
            profession = field; break
        default: break
        }
        return cell
    }
 
}