//
//  EditProfileDetailTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EditProfileDetailTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    var itemType : QuickViewCategory?
    var item : UserDetail?
    var fields : [UITextField] = []
    let picker = UIPickerView()
    var years = [String]()
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var type : FieldType?
    var switchView = UISwitch(translates: false)
    var index : IndexPath?
    let delete = UIButton(type: .system).then {
        $0.constrain((.height, 80)); $0.titleColor = .red; $0.translates = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = item {
            title = "Edit " + item.category.title()
            delete.title = "Delete " + item.category.title()
            delete.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
            tableView.addSubview(delete)
            delete.constrain(.leading, .width, toItem: tableView)
            delete.constrain(.top, constant: tableView.frame.size.height - (80 * 2), toItem: tableView)
        } else {
            title = "Add " + (itemType?.title() ?? "")
        }
        
        tableView.registerClass(UITableViewCell.self, EditFieldsTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 70
        tableView.allowsSelection = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        
        picker.delegate = self; picker.dataSource = self
        
        let year = NSCalendar.autoupdatingCurrent.dateComponents([.year], from: Date()).year!
        for index in 0...70 { years.append(String(describing: year - index)) }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return itemType?.editFields().count ?? 0 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let field = itemType?.editFields()[indexPath.row] as EditField! else { return UITableViewCell() }
        if field.type == .toggle {
            let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.textLabel?.text = field.placeholder
            switchView.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
            cell.addSubview(switchView)
            switchView.constrain((.top, 15), (.bottom, -15), (.trailing, -10), toItem: cell)
            if field.type == .toggle && item != nil { switchView.setOn((item?.fieldValues()[safe: indexPath.row] as? Bool) ?? false, animated: false) }
            return cell
        }
        
        let cell = tableView.dequeue(EditFieldsTableViewCell.self, indexPath: indexPath)
        cell.configure(twoFields: field.type == .month)
        fields.append(cell.first)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cell.first.placeholder = field.placeholder
        cell.first.delegate = self; cell.second.delegate = self
        if field.type == .month || field.type == .year { cell.second.inputView = picker; cell.first.inputView = picker; type = field.type }
        
        guard let item = item as UserDetail! else { return cell }
        if field.type == .text { cell.first.text = item.fieldValues()[safe: indexPath.row] as? String }
        if field.type == .year { cell.first.text = item.fieldValues()[safe: indexPath.row] as? String }
        if field.type == .month {
            let monthYear = item.fieldValues()[safe: indexPath.row] as? [String]
            cell.first.text = monthYear?[safe: 0]; cell.second.text = monthYear?[safe: 1]
            fields.append(cell.second)
        }

        return cell
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = InputToolbar(fields)
        guard textField.inputView == picker else { return }
        guard let cell = textField.superview as? EditFieldsTableViewCell else { return }
        index = tableView.indexPath(for: cell)

        if type == .month && cell.first.text == "" {
            cell.first.text = months[0]
            cell.second.text = years[0]; return
        } else if cell.first.text == "" {
            cell.first.text = years[0]; return
        }
        
        if type == .month {
            let month = months.index(of: cell.first.text!) ?? 0
            let year = years.index(of: cell.second.text!) ?? 0
            if picker.selectedRow(inComponent: 0) != month { picker.selectRow(month, inComponent: 0, animated: true) }
            if picker.selectedRow(inComponent: 1) != year { picker.selectRow(year, inComponent: 1, animated: true) }
        } else {
            let index = years.index(of: cell.first.text!)!
            if picker.selectedRow(inComponent: 0) != index { picker.selectRow(index, inComponent: 0, animated: true) }
        }
    }
    
    func switchChanged(sender: UISwitch) { }
    
    func save() {
        var request : ProfileRequest
        
        if item!.category == .education {
            request = ProfileRequest(schools: [SchoolModel(id: "7567656")])
        } else { // .experience
            var id = "", start_month = "", start_year = "", end_month = "", end_year = "", title = ""
            let current = switchView.isOn
            var company : CompanyModel?

            for (index, _) in type(of:item!).fields.enumerated() {
                guard let cell = tableView.cellForRow(at: IndexPath(item: index, section: 0)) as? EditFieldsTableViewCell else { continue }
                switch index {
                case 0: id = "1681681"; break//cell.first.text ?? ""; break
                case 1: title = cell.first.text ?? ""; break
                case 2: start_month = cell.first.text ?? ""; start_year = cell.second.text ?? ""; break
                case 3: end_month = cell.first.text ?? ""; end_year = cell.second.text ?? ""; break
                default: break }
            }
            company = CompanyModel(id: id, start_month: start_month, start_year: start_year, end_month: end_month, end_year: end_year, current: current)
            request = ProfileRequest(title: title, companies: [company!])
        }

        Client.execute(request, complete: { _ in self.navigationController?.pop() })
    }
    
    func deleteItem() { }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int { return type == .month ? 2 : 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if type == .month { return component == 0 ? months.count : years.count }
        return years.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if type == .month { return component == 0 ? months[row] : years[row] }
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
