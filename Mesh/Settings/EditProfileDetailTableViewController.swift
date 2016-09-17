//
//  EditProfileDetailTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EditProfileDetailTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    var item : UserDetail?
    let picker = UIPickerView()
    var years = [String]()
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var type : FieldType?
    var index : IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, EditFieldsTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 70
        tableView.allowsSelection = false
        
        picker.delegate = self
        picker.dataSource = self
        
        let year = NSCalendar.autoupdatingCurrent.dateComponents([.year], from: Date()).year!
        for index in (year - 70)...year {
            years.append(String(describing: index))
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return item?.fields.count ?? 0 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.item?.fields[indexPath.row]
        if item?.type == .toggle {
            let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.textLabel?.text = item?.placeholder
            let switchView = UISwitch(translates: false)
            switchView.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
            cell.addSubview(switchView)
            switchView.constrain(.bottom, .trailing, toItem: cell)
            switchView.constrain((.top, 15), (.bottom, -15), toItem: cell)
            return cell
        }
        
        let cell = tableView.dequeue(EditFieldsTableViewCell.self, indexPath: indexPath)
        cell.configure(twoFields: item?.type == .month)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cell.first.placeholder = item?.placeholder ?? ""
        cell.first.delegate = self; cell.second.delegate = self
        if item?.type == .month || item?.type == .year { cell.second.inputView = picker; cell.first.inputView = picker; type = item?.type }
        return cell
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField.inputView == picker else { return }
        guard let cell = textField.superview as? EditFieldsTableViewCell else { return }
        index = tableView.indexPath(for: cell)
        picker.selectRow(50, inComponent: type == .month ? 1 : 0, animated: false)

        if type == .month && cell.first.text == "" {
            cell.first.text = months[0]
            cell.second.text = years[50]; return
        } else if cell.first.text == "" {
            cell.first.text = years[50]; return
        }
        
        if type == .month {
            let month = months.index(of: cell.first.text!) ?? 0
            let year = years.index(of: cell.second.text!) ?? 0
            picker.selectRow(month, inComponent: 0, animated: true)
            picker.selectRow(year, inComponent: 1, animated: true)
        } else {
            let index = years.index(of: cell.first.text!)!
            picker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    func switchChanged(sender: UISwitch) {
        
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int { return type == .month ? 2 : 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if type == .month { return component == 0 ?  months.count : years.count }
        return years.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if type == .month { return component == 0 ?  months[row] : years[row] }
        return years[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let cell = tableView.cellForRow(at: index!) as? EditFieldsTableViewCell else { return }
        let year = years[row]        
        if type == .month && component == 0 { let month = months[row]; cell.first.text = month; return }
        if type == .month && component == 1 { cell.second.text = year; return }
        cell.first.text = year
    }
}
