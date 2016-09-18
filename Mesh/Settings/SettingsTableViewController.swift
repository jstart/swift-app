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
    
    var cellModels : [SettingCell] {
        switch self {
        case .ConnectedAccounts: return [SettingCell("Twitter", slider: true), SettingCell("Google", slider: true)]
        case .MatchSettings: return [SettingCell("Location"), SettingCell("I'm Interested In")]
        case .GeneralSettings: return [SettingCell("Add Email"), SettingCell("Edit Phone Number"), SettingCell("Change Password"), SettingCell("Edit Name")]
        case .PushNotifications: return [SettingCell("TBD")]
        case .EmailNotifications: return [SettingCell("TBD")]
        case .ContactUs: return [SettingCell("Help & Support", accessoryType: .none, textAlignment: .center)]
        case .Legal: return [SettingCell("Privacy Policy"), SettingCell("Terms of Service"), SettingCell("Licenses")]
        case .Logout: return [SettingCell("Logout", accessoryType: .none, textAlignment: .center)]
        case .DeleteAccount: return [SettingCell("Delete Account", accessoryType: .none, textAlignment: .center)] }
    }
}

struct SettingCell {
    var title: String, accessoryType: UITableViewCellAccessoryType, textAlignment: NSTextAlignment, image: UIImage?, slider: Bool
    
    init(_ title: String, accessoryType: UITableViewCellAccessoryType = .disclosureIndicator, textAlignment: NSTextAlignment = .left, image: UIImage? = nil, slider: Bool = false) {
        self.title = title
        self.accessoryType = slider ? .none : accessoryType
        self.textAlignment = textAlignment
        self.image = image
        self.slider = slider
    }
}

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerClass(UITableViewCell.self)
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
        let settings = Settings(rawValue: indexPath.section)?.cellModels[indexPath.row]
        cell.textLabel?.text = settings?.title
        cell.textLabel?.textAlignment = (settings?.textAlignment)!
        cell.accessoryType = (settings?.accessoryType)!
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Settings(rawValue: indexPath.section)! {
        case .ConnectedAccounts: break
        case .MatchSettings: break
        case .GeneralSettings: editUser(indexPath.row); break
        case .PushNotifications: break
        case .EmailNotifications: break
        case .ContactUs: contactUs(); break
        case .Legal: legal(); break
        case .Logout: logout(); break
        case .DeleteAccount: delete(); break }
    }
    
    func editUser(_ row: Int) {
        switch row {
        case 0: navigationController?.push(UserEditEmailViewController()); break
        case 1: navigationController?.push(UserEditPhoneViewController()); break
        case 2: navigationController?.push(UserEditPasswordViewController()); break
        case 3: navigationController?.push(UserEditNameViewController()); break
        default: break }
    }
    
    func contactUs() { }
    
    func legal() { }
    
    func logout() { Client.execute(LogoutRequest(), completionHandler: { response in NotificationCenter.default.post(name: .logout, object: nil) }) }
    
    func delete() { }

}
