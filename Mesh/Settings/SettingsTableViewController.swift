//
//  SettingsTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import AlamofireImage

enum Settings : Int {
    case ConnectedAccounts, MatchSettings, GeneralSettings, PushNotifications, EmailNotifications, ContactUs, Legal, Logout, DeleteAccount
    
    var title : String {
        switch self {
        case .ConnectedAccounts: return "Connected Accounts"
        case .MatchSettings: return "Match Settings"
        case .GeneralSettings: return "General Settings"
        case .PushNotifications: return "Push Notifications"
        case .EmailNotifications: return "Email Notifications"
        case .ContactUs: return "Contact Us"
        case .Legal: return "Legal"
        case .Logout: return ""
        case .DeleteAccount: return "" }
    }
    
    var numberOfRows : Int {
        switch self {
        case .ConnectedAccounts: return 2
        case .MatchSettings: return 2
        case .GeneralSettings: return 4
        case .PushNotifications: return 1
        case .EmailNotifications: return 1
        case .ContactUs: return 1
        case .Legal: return 3
        case .Logout: return 1
        case .DeleteAccount: return 1 }
    }
    
    var cellModels : [String] {
        switch self {
        case .ConnectedAccounts: return ["Twitter", "Google"]
        case .MatchSettings: return ["Location", "I'm Interested In"]
        case .GeneralSettings: return ["Add Email", "Add Phone Number", "Change Password", "Edit Name"]
        case .PushNotifications: return ["TBD"]
        case .EmailNotifications: return ["TBD"]
        case .ContactUs: return ["Help & Support"]
        case .Legal: return ["Privacy Policy", "Terms of Service", "Licenses"]
        case .Logout: return ["Logout"]
        case .DeleteAccount: return ["Delete Account"] }
    }
}

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let profileImage = UIImageView(translates: false).then { $0.constrain(.height, .width, constant: 40) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 9 }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return Settings(rawValue: section)?.title }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return Settings(rawValue: section)?.numberOfRows ?? 0 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
        cell.textLabel?.text = Settings(rawValue: indexPath.section)?.cellModels[indexPath.row]
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Settings(rawValue: indexPath.section)! {
        case .ConnectedAccounts: break
        case .MatchSettings: break
        case .GeneralSettings: break
        case .PushNotifications: break
        case .EmailNotifications: break
        case .ContactUs: contactUs(); break
        case .Legal: legal(); break
        case .Logout: logout(); break
        case .DeleteAccount: delete(); break }
    }
    
    func contactUs() { }
    
    func legal() { }
    
    func logout() {
        Client.execute(LogoutRequest(), completionHandler: { response in NotificationCenter.default.post(name: .logout, object: nil) })
    }
    
    func delete() { }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss()
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        let data = UIImageJPEGRepresentation(image, 0.1)
        Client.upload(PhotoRequest(file: data!), completionHandler: { response in
            if response.result.value != nil {
                let alert = UIAlertController(title: "Photo Updated", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction.ok())
                self.present(alert)
            }
            else {
                let alert = UIAlertController(title: "Error", message: response.result.error?.localizedDescription ?? "Unknown Error", preferredStyle: .alert)
                alert.addAction(UIAlertAction.ok())
                self.present(alert)
            }
        })
    }

}
