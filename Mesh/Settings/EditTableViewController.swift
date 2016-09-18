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

    var phone : UITextField?
    var first_name : UITextField?
    var last_name : UITextField?
    var email : UITextField?
    var titleField : UITextField?
    var profession : UITextField?
    
    let profile = UIImageView(translates: false).then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.constrain(.height, constant: 325)
    }
    
    var items : [UserDetail] = [Experience(company: "Tinder", position: "iOS", startYear: "2012", endYear: "2016"),
                                Education(schoolName: "Harvard", degreeType: "Masters", startYear: "2012", endYear: "2016"),
                                Skill(name: "iOS Development", numberOfMembers: "2,000 Members", isAdded: true)]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "My Profile"
        
        tableView.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        tableView.registerClass(UITableViewCell.self); tableView.registerNib(UserDetailTableViewCell.self)
        tableView.estimatedRowHeight = 100
        navigationItem.rightBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "connectionsOverflow"), style: .done, target: self, action: #selector(settings))
    }
    
    func settings() { navigationController?.push(SettingsTableViewController(style: .grouped)) }
    
    func save() {
        //let phone_number = self.phone?.text
        let first_name = self.first_name?.text
        let last_name = self.last_name?.text
        let email = self.email?.text
        let title = self.titleField?.text
        let profession = self.profession?.text
        
        let companies = [CompanyModel(id: "tinder", start_month: "January", start_year: "2014", end_month: "March", end_year: "2016", current: false)]
        Client.execute(ProfileRequest(first_name: first_name, last_name: last_name, email: email, title: title, profession: profession, companies: companies), completionHandler: { response in
            if response.result.value != nil {
                let alert = UIAlertController(title: "Profile Updated", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction.ok() { _ in self.navigationController?.pop() })
                self.present(alert)
            } else {
                let alert = UIAlertController(title: "Error", message: response.result.error?.localizedDescription ?? "Unknown Error", preferredStyle: .alert)
                alert.addAction(UIAlertAction.ok())
                self.present(alert)
            }
        })
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 4 }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Experience"
        case 2: return "Education"
        case 3: return "Skills"
        default: return "" }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 1.0 }
        return 50
    }
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
            
            switch indexPath.row {
            case 0: break
            default: break }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 { photoOptions() }
        navigationController?.push(EditProfileListTableViewController())
    }
    
    func uploadChoice(_ sender: UIAlertAction) {
        if sender.title == "Import from Twitter"{
            TwitterProfile.prefillImage() { response in
                self.profile.af_setImage(withURL: URL(string: response.image_url)!) { response in
                    guard let image = response.result.value else { return }
                    self.upload(image)
                }
            }
        } else if sender.title == "Import from Google" {
            GIDSignIn.sharedInstance().uiDelegate = self
            GoogleProfile.shared.prefillImage() { response in
                guard response.image_url != "" else { return }
                self.profile.af_setImage(withURL: URL(string: response.image_url)!) { response in
                    guard let image = response.result.value else { return }
                    self.upload(image)
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
        
        let sheet = UIAlertController(title: "Add Profile Photo", message: nil, preferredStyle: .actionSheet)
        sheet.addActions(twitter, google, library, UIAlertAction.cancel())
        present(sheet)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss()
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        profile.image = image
        upload(image)
    }
    
    func upload(_ image: UIImage?) {
        guard let image = image as UIImage! else { return }
        let data = UIImageJPEGRepresentation(image, 1.0)
        Client.upload(PhotoRequest(file: data!), completionHandler: { response in
            let alert : UIAlertController?
            if response.result.value != nil {
                alert = UIAlertController(title: "Photo Updated", message: "", preferredStyle: .alert)
            } else {
                alert = UIAlertController(title: "Error", message: response.result.error?.localizedDescription ?? "Unknown Error", preferredStyle: .alert)
            }
            alert?.addAction(UIAlertAction.ok())
            self.present(alert!)
        })
    }
 
}
