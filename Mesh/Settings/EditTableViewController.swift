//
//  EditTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/1/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import GoogleSignIn

class EditTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GIDSignInUIDelegate {
    
    let profile = UIImageView(translates: false).then {
        $0.contentMode = .scaleAspectFill; $0.clipsToBounds = true
        $0.constrain(.height, constant: 325)
    }
    let editIcon = UIImageView(image: #imageLiteral(resourceName: "edit").withRenderingMode(.alwaysTemplate)).then {
        $0.translates = false; $0.tintColor = .white; $0.isHidden = false; $0.constrain(.width, .height, constant: 12)
    }
    let editLabel = UILabel(translates: false).then {
        $0.text = "Edit"; $0.textColor = .white; $0.font = .semiboldProxima(ofSize: 14); $0.isHidden = false
    }
    var items : [UserDetail] = [Experience(company: "Tinder", position: "iOS", startMonth: "January", startYear: "2012", endMonth: "January", endYear: "2016"),
                                Education(schoolName: "Harvard", degreeType: "Masters", startYear: "2012", endYear: "2016", field: "Engineering", graduated: true),
                                Skill(name: "iOS Development", numberOfMembers: "2,000 Members", isAdded: true)]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "My Profile"
        
        tableView.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        tableView.registerClass(UITableViewCell.self); tableView.registerNib(UserDetailTableViewCell.self)
        tableView.estimatedRowHeight = 100
        navigationItem.rightBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "mainNavSettings").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(settings))
    }
    
    func settings() { navigationController?.push(SettingsTableViewController(style: .grouped)) }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 4 }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section != 0 else { return nil }
        let header = UIButton().then { $0.backgroundColor = .white }
        let icon = UIImageView(translates: false).then { $0.contentMode = .scaleAspectFit }
        let title = UILabel(translates: false).then { $0.font = .proxima(ofSize: 14); $0.textColor = .lightGray }
        let edit = UIImageView(translates: false).then { $0.image = #imageLiteral(resourceName: "edit") }
        header.addSubviews(icon, title, edit)

        icon.constrain((.leading, 15), (.centerY, 0), toItem: header)
        icon.constrain(.height, .width, constant: 16)
        title.constrain((.centerY, 0), toItem: icon)
        title.constrain(.leading, constant: 10, toItem: icon, toAttribute: .trailing)
        title.constrain(.trailing, constant: -10, toItem: edit, toAttribute: .leading)
        edit.constrain((.trailing, -30), (.centerY, 0), toItem: header)
        edit.constrain(.height, .width, constant: 20)
        
        var selector : Selector?
        switch section {
        case 1: title.text = "Experience"; icon.image = #imageLiteral(resourceName: "experience"); selector = #selector(editExperience)
        case 2: title.text = "Education"; icon.image = #imageLiteral(resourceName: "education"); selector = #selector(editEducation)
        case 3: title.text = "Skills"; icon.image = #imageLiteral(resourceName: "skills"); selector = #selector(editSkills); default: break }
        
        header.addTarget(self, action: selector!, for: .touchUpInside)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { if section == 0 { return 1.0 }; return 50 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return section == 0 ? 2 : 1 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
            switch indexPath.row {
            case 0:
                cell.addSubview(profile)
                profile.constrain(.leading, .trailing, .top, .bottom, toItem: cell)
                guard let url = URL(string: UserResponse.current?.photos?.large ?? "") as URL! else { return cell }
                profile.af_setImage(withURL: url)
                
                profile.addSubviews(editIcon, editLabel)
                editLabel.constrain((.bottom, -5), (.trailing, -10), toItem: profile)
                editIcon.constrain(.centerY, toItem: editLabel)
                editIcon.constrain(.trailing, constant: -5, toItem: editLabel, toAttribute: .leading)
                break
            case 1:
                cell.selectionStyle = .none
                cell.textLabel?.font = .boldProxima(ofSize: 20)
                cell.textLabel?.text = UserResponse.current?.fullName(); break
            default: break }
            return cell
        } else {
            let cell = tableView.dequeue(UserDetailTableViewCell.self, indexPath: indexPath)
            
            let item = items[indexPath.section - 1]
            
            cell.icon.image = #imageLiteral(resourceName: "tesla")
            
            cell.button.isHidden = true
            cell.year.isHidden = !item.hasDate
            
            cell.top.text = item.firstText
            cell.bottom.text = item.secondText
            cell.year.text = item.thirdText
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 { photoOptions(); return }
        if indexPath.section == 0 && indexPath.row == 1 { return }
        let edit = EditProfileListTableViewController()
        
        var type : QuickViewCategory
        switch indexPath.section - 1 {
        case 0: type = .experience; break
        case 1: type = .education; break
        case 2: type = .skills; break
        default: type = .experience; break }
        edit.itemType = type
        if items.count > 0 {
            edit.items = [items[indexPath.section - 1]]
        }
        navigationController?.push(edit)
    }
    
    func editExperience() {
        let edit = EditProfileListTableViewController(); edit.itemType = .experience
        if items.count > 0 { edit.items = [items[0]] }
        navigationController?.push(edit)
    }
    
    func editEducation() {
        let edit = EditProfileListTableViewController(); edit.itemType = .education
        if items.count > 0 { edit.items = [items[1]] }
        navigationController?.push(edit)
    }
    
    func editSkills() {
        let edit = EditProfileListTableViewController(); edit.itemType = .skills
        if items.count > 0 { edit.items = [items[2]] }
        navigationController?.push(edit)
    }
    
    func uploadChoice(_ sender: UIAlertAction) {
        if sender.title == "Import from Twitter"{
            TwitterProfile.prefillImage() { response in
                guard let imageURL = response?.image_url else { return }
                self.profile.af_setImage(withURL: URL(string: imageURL)!) { response in
                    guard let image = response.result.value else { return }; self.upload(image)
                }
            }
        } else if sender.title == "Import from Google" {
            GIDSignIn.sharedInstance().uiDelegate = self
            GoogleProfile.shared.prefillImage() { response in
                guard response?.image_url != "" else { return }
                self.profile.af_setImage(withURL: URL(string: response!.image_url)!) { response in
                    guard let image = response.result.value else { return }; self.upload(image)
                }
            }
        } else if sender.title == "Choose from Library" {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            present(picker)
        }
    }
    
    func photoOptions() {
        let twitter = UIAlertAction("Import from Twitter") { sender in self.uploadChoice(sender)}
        let google = UIAlertAction("Import from Google") { sender in self.uploadChoice(sender)}
        let library = UIAlertAction("Choose from Library") { sender in self.uploadChoice(sender)}
        
        let sheet = UIAlertController.sheet(title: "Add Profile Photo")
        sheet.addActions(twitter, google, library, UIAlertAction.cancel())
        present(sheet)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss()
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        profile.image = image; upload(image)
    }
    
    func upload(_ image: UIImage?) {
        guard let image = image as UIImage! else { return }
        let data = UIImageJPEGRepresentation(image, 1.0)
        Client.upload(PhotoRequest(file: data!), completionHandler: { response in
            let alert : UIAlertController?
            if response.result.value != nil { alert = UIAlertController.alert(title: "Photo Updated") }
            else { alert = UIAlertController.alert(title: "Error", message: response.result.error?.localizedDescription ?? "Unknown Error") }
            alert?.addAction(UIAlertAction.ok())
            self.present(alert!)
        })
    }
 
}
