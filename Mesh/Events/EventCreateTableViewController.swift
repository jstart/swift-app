//
//  EventCreateTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EventCreateTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var fields : [UITextField] = []
    var currentField : UITextField?
    let fieldModels : [EditField] = [("Name of Event", .text), ("Start Time", .month), ("End Time", .month), ("Location", .autocomplete), ("Related Industry & Skills", .autocomplete), ("More Info", .text)]
    var index : IndexPath?
    var firstDate, secondDate: Date?
    let datePicker = UIDatePicker()
    /*let delete = UIButton(type: .system).then {
        $0.constrain((.height, 80))
        $0.setTitleColor(.red, for: .normal)
        $0.translates = false
    }*/
    let imageHeader = UIImageView(translates: false).then {
        $0.isUserInteractionEnabled = true
        $0.clipsToBounds = true
        $0.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        $0.contentMode = .center
        $0.image = #imageLiteral(resourceName: "enableCameraAccess").withRenderingMode(.alwaysTemplate)
        $0.tintColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
        $0.constrain((.height, 160))
    }
    let formatter = DateFormatter().then {
        $0.dateFormat = "MMMM dd, yyyy - h a"
        $0.locale = Locale.autoupdatingCurrent
    }
    let locationDataSource = AutoCompleteLocationDataSource()
    let interestsDataSource = AutoCompleteDetailDataSource()
    let autoCompleteView = AutoCompleteView()
    let interestsAutoCompleteView = AutoCompleteView()

    override func viewDidLoad() {
        super.viewDidLoad()

        /*delete.setTitle("Delete Event", for: .normal)
        delete.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        tableView.addSubview(delete)
        delete.constrain(.leading, .width, toItem: tableView)
        delete.constrain(.top, constant: tableView.frame.size.height - (80 * 2), toItem: tableView)*/
        
        title = "Create Event"
        
        tableView.registerClass(UITableViewCell.self, EditFieldsTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 70
        tableView.allowsSelection = false
        
        tableView.tableHeaderView = imageHeader
        imageHeader.constrain(.leading, .trailing, .width, toItem: tableView)
        imageHeader.layoutIfNeeded()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageUpload))
        imageHeader.addGestureRecognizer(tap)
        tableView.tableHeaderView = imageHeader
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(create))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        datePicker.addTarget(self, action: #selector(dateChanged(sender:)), for: .valueChanged)
        
        autoCompleteView.dataSource = locationDataSource
        autoCompleteView.delegate = locationDataSource
        
        locationDataSource.didSelect = { result in
            self.currentField?.resignFirstResponder()
            guard let result = result else { return }
            self.fields[3].text = result.title
        }
        
        interestsAutoCompleteView.dataSource = interestsDataSource
        interestsAutoCompleteView.delegate = interestsDataSource
        interestsDataSource.didUpdate = { self.interestsAutoCompleteView.reloadData() }

        interestsDataSource.didSelect = { result in
            self.currentField?.resignFirstResponder()
            self.fields[4].text = result.firstText
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return fieldModels.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let field = fieldModels[indexPath.row] as EditField! else { return UITableViewCell() }

        let cell = tableView.dequeue(EditFieldsTableViewCell.self, indexPath: indexPath)
        cell.configure()
        fields.append(cell.first)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cell.first.placeholder = field.placeholder; cell.first.delegate = self
        
        if field.type == .month { cell.first.inputView = datePicker }
        if field.type == .autocomplete {
            cell.first.addTarget(self, action: #selector(autocompleteChanged(sender:)), for: .allEditingEvents)
            LocationManager.shared.searchCompletion = { self.autoCompleteView.reloadData() }
        }
        
        return cell
    }
    
    func autocompleteChanged(sender: UITextField) {
        if sender == fields[3] { locationDataSource.filter(sender.text!) }
        if sender == fields[4] { interestsDataSource.filter(sender.text!) }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentField = textField; textField.inputAccessoryView = InputToolbar(fields)
        if textField.inputView == datePicker && textField.text == "" {
            dateChanged(sender: datePicker)
        }
        if currentField == fields[1] { datePicker.setDate(firstDate!, animated: true) }
        else if currentField == fields[2] { datePicker.setDate(secondDate!, animated: true) }
        else if currentField == fields[3] || currentField == fields[4] {
            if autoCompleteView.constraints.count == 0 && currentField == fields[3] {
                autoCompleteView.constrainTo(field: currentField!, inViewController: self); autoCompleteView.isHidden = false
            }
            else if interestsAutoCompleteView.constraints.count == 0 && currentField == fields[4] {
                interestsAutoCompleteView.constrainTo(field: currentField!, inViewController: self); interestsAutoCompleteView.isHidden = false
            }
            UIView.animate(withDuration: 0.2, animations: { _ in
                self.tableView.contentInset = UIEdgeInsets(top: (10 - textField.convert(textField.frame, to: self.tableView).origin.y), left: 0, bottom: 0, right: 0)
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: { _ in
                self.tableView.contentInset = UIEdgeInsets(top: (10 - textField.convert(textField.frame, to: self.tableView).origin.y), left: 0, bottom: 0, right: 0)
            })
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if currentField == fields[3] { autoCompleteView.isHidden = true; autoCompleteView.removeConstraints(autoCompleteView.constraints); DefaultNotification.removeObserver(autoCompleteView) }
        if currentField == fields[4] { interestsAutoCompleteView.isHidden = true; interestsAutoCompleteView.removeConstraints(interestsAutoCompleteView.constraints); DefaultNotification.removeObserver(interestsAutoCompleteView) }
        UIView.animate(withDuration: 0.2, animations: { _ in
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        })
    }
    
    func dateChanged(sender: UIDatePicker) {
        if currentField == fields[1] { currentField?.text = formatter.string(from: sender.date); firstDate = sender.date }
        if currentField == fields[2] { currentField?.text = formatter.string(from: sender.date); secondDate = sender.date }
    }
    
    func imageUpload() {
        let picker = UIImagePickerController(); picker.sourceType = .photoLibrary; picker.delegate = self
        present(picker)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss()
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        imageHeader.contentMode = .scaleAspectFill
        imageHeader.image = image
        imageHeader.layoutIfNeeded()
        tableView.tableHeaderView = imageHeader
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func create() {
        var name, description : String?, start_time = firstDate, end_time = secondDate
        for (index, _) in fieldModels.enumerated() {
            switch index {
            case 0: name = fields[0].text; break
            case 5: description = fields[5].text; break
            default: break }
        }

        Client.execute(EventCreateRequest(name: name!, logo: UserResponse.current!.photos!.large!, description: description!, interests: [0], start_time: start_time!.timeIntervalSince1970, end_time: end_time!.timeIntervalSince1970)) { _ in
            let alert = UIAlertController.alert(title: "Event Created")
            let cancel = UIAlertAction.ok() { _ in self.navigationController?.pop() }
            alert.addAction(cancel)
            self.present(alert)
        }
    }
    
    //func deleteItem() { }
    
}
