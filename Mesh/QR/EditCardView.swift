//
//  EditCardView.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EditCardView : CardView, UITableViewDelegate, UITableViewDataSource {
    
    var cancelHandler : (() -> Void)?
    var doneHandler : (([ProfileFields]) -> Void)?
    var fields : [ProfileFields]?

    let tableView = UITableView(translates: false).then {
        $0.separatorStyle = .none
        $0.tableFooterView = UIView()
        $0.registerClass(EditCardTableViewCell.self)
    }
    let cancel = UIButton(translates: false).then {
        $0.setTitle("CANCEL", for: .normal)
        $0.titleLabel?.font = .gothamMedium(ofSize: 18)
        $0.backgroundColor = .lightGray
        $0.setTitleColor(.white, for: .normal)
        $0.constrain(.height, constant: 50)
    }
    let done = UIButton(translates: false).then {
        $0.setTitle("DONE", for: .normal)
        $0.titleLabel?.font = .gothamMedium(ofSize: 18)
        $0.backgroundColor = Colors.brand
        $0.setTitleColor(.white, for: .normal)
        $0.constrain(.height, constant: 50)
    }
    var phoneNumber: String?
    var formatter = PhoneNumberFormatter()
    
    convenience init(_ user: UserResponse) {
        self.init()
        clipsToBounds = true
        layer.shadowColor = UIColor.clear.cgColor
        addSubviews(tableView, cancel, done)
        tableView.dataSource = self
        tableView.delegate = self
        
        cancel.addTarget(self, action: #selector(cancelPressed(sender:)), for: .touchUpInside)
        done.addTarget(self, action: #selector(donePressed(sender:)), for: .touchUpInside)
        
        if let phone = UserResponse.current?.phone_number {
            phoneNumber = formatter.format(phone)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.constrain(.width, .centerX, .top, toItem: self)
        tableView.constrain((.height, -50), toItem: self)
        cancel.constrain(.trailing, toItem: done, toAttribute: .leading)
        cancel.constrain(.leading, .bottom, toItem: self)
        done.constrain(.trailing, .bottom, toItem: self)
        cancel.constrain(.width, toItem: done)
        tableView.reloadData()
    }
    
    func cancelPressed(sender: UIButton) { cancelHandler?() }
    func donePressed(sender: UIButton) { doneHandler?(fields!) }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 4 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(EditCardTableViewCell.self, indexPath: indexPath)
        cell.icon.tintColor = Colors.brand
        switch indexPath.row {
        case 0:
            cell.icon.image = ProfileFields.name.image.withRenderingMode(.alwaysTemplate)
            cell.contactField.text = UserResponse.current?.fullName()
            cell.setChecked(fields?.contains(.name) ?? false)
            break
        case 1:
            cell.icon.image = ProfileFields.title.image.withRenderingMode(.alwaysTemplate)
            cell.contactField.text = UserResponse.current?.fullTitle()
            cell.setChecked(fields?.contains(.title) ?? false)
            break
        case 2:
            cell.icon.image = ProfileFields.email.image.withRenderingMode(.alwaysTemplate)
            cell.contactField.text = "\(UserResponse.current!.first_name!).\(UserResponse.current!.last_name!)@ripple.com"//UserResponse.current?.email
            cell.setChecked(fields?.contains(.email) ?? false)
            break
        case 3:
            cell.icon.image = ProfileFields.phone.image.withRenderingMode(.alwaysTemplate)
            cell.contactField.text = phoneNumber
            cell.setChecked(fields?.contains(.phone) ?? false)
            break
        default: break }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EditCardTableViewCell
        guard let fields = fields else { return }
        let field = ProfileFields(rawValue: indexPath.row)!
        if field == .name { return }
        cell.setChecked(!fields.contains(field))
        if !fields.contains(field) {
            self.fields?.append(field)
        }else {
            let index = self.fields?.index(of: field)
            self.fields?.remove(at: index!)
        }
    }
}
