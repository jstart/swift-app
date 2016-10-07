//
//  SettingsTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import MessageUI
import TwitterKit
import GoogleSignIn

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
        case .Logout: return ""; case .DeleteAccount: return "" }
    }
    
    var numberOfRows : Int {
        switch self {
        case .ConnectedAccounts: return 3
        case .MatchSettings: return 2
        case .GeneralSettings: return 4
        case .PushNotifications: return 1
        case .EmailNotifications: return 1
        case .ContactUs: return 1
        case .Legal: return 3
        case .Logout: return 1; case .DeleteAccount: return 1 }
    }
    
    var cellModels : [SettingCell] {
        switch self {
        case .ConnectedAccounts: return [SettingCell("Twitter", hasSwitch: true), SettingCell("Google", hasSwitch: true), SettingCell("Medium", hasSwitch: true)]
        case .MatchSettings: return [SettingCell("Location"), SettingCell("I'm Interested In")]
        case .GeneralSettings: return [SettingCell("Add Email"), SettingCell("Edit Phone Number"), SettingCell("Change Password"), SettingCell("Edit Name")]
        case .PushNotifications: return [SettingCell("TBD")]
        case .EmailNotifications: return [SettingCell("TBD")]
        case .ContactUs: return [SettingCell("Help & Support", accessoryType: .none, textAlignment: .center)]
        case .Legal: return [SettingCell("Privacy Policy"), SettingCell("Terms of Service"), SettingCell("Licenses")]
        case .Logout: return [SettingCell("Logout", accessoryType: .none, textAlignment: .center)]; case .DeleteAccount: return [SettingCell("Delete Account", accessoryType: .none, textAlignment: .center)] }
    }
}

struct SettingCell {
    var title: String, accessoryType: UITableViewCellAccessoryType, textAlignment: NSTextAlignment, image: UIImage?, hasSwitch: Bool
    
    init(_ title: String, accessoryType: UITableViewCellAccessoryType = .disclosureIndicator, textAlignment: NSTextAlignment = .left, image: UIImage? = nil, hasSwitch: Bool = false) {
        self.title = title
        self.accessoryType = hasSwitch ? .none : accessoryType
        self.textAlignment = textAlignment
        self.image = image
        self.hasSwitch = hasSwitch
    }
}

class SettingsTableViewController: UITableViewController, GIDSignInUIDelegate, MFMailComposeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(UITableViewCell.self)        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 9 }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return Settings(rawValue: section)?.title }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return Settings(rawValue: section)?.numberOfRows ?? 0 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
        
        let section = Settings(rawValue: indexPath.section)!
        if section == .MatchSettings && indexPath.row == 0 {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "")
            cell.detailTextLabel?.text = LocationManager.cityState()
        }
        
        let switchView = UISwitch()
        switchView.tag = indexPath.row
        if Twitter.sharedInstance().sessionStore.session() != nil && indexPath.row == 0 { switchView.setOn(true, animated: false) }
        if GoogleProfile.isLoggedIn() && indexPath.row == 1 { switchView.setOn(true, animated: false) }
        if MediumSDKManager.isAuthorized() && indexPath.row == 2 { switchView.setOn(true, animated: false) }

        switchView.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
        cell.accessoryView = section == .ConnectedAccounts ? switchView : nil
        
        let settings = section.cellModels[indexPath.row]
        cell.textLabel?.text = settings.title
        cell.textLabel?.textAlignment = settings.textAlignment
        cell.accessoryType = settings.accessoryType
        
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
        case .Legal: legal(indexPath.row); break
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
    
    func contactUs() {
        if !MFMailComposeViewController.canSendMail() { return }
        let mail = MFMailComposeViewController(); mail.setToRecipients(["christopher@tinderventures.com"]); mail.mailComposeDelegate = self
        present(mail)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) { controller.dismiss() }
    
    func legal(_ row: Int) {
        switch row {
        case 0: navigationController?.safari("https://www.gotinder.com/privacy"); break
        case 1: navigationController?.safari("https://www.gotinder.com/terms"); break
        case 2: navigationController?.safari("https://www.gotinder.com/safety"); break
        default: break }
    }
    
    func logout() { Client.execute(LogoutRequest(), complete: { response in NotificationCenter.default.post(name: .logout, object: nil) }) }
    
    func delete() { }
    
    func switchChanged(sender: UISwitch) {
        switch sender.tag {
        case 0:
            guard sender.isOn else {
                if let session = Twitter.sharedInstance().sessionStore.session() {
                    Twitter.sharedInstance().sessionStore.logOutUserID(session.userID)
                }; return
            }
            TwitterProfile.prefill({ response in
                if response == nil { sender.setOn(false, animated: true); return }
                let token = Twitter.sharedInstance().sessionStore.session()?.authToken, secret = Twitter.sharedInstance().sessionStore.session()?.authTokenSecret
                Client.execute(TwitterConnectRequest(twitter_token: token!, twitter_secret: secret!))
            })
        case 1:
            guard sender.isOn else { return }
            GIDSignIn.sharedInstance().uiDelegate = self
            GoogleProfile.shared.prefill({ response in
                if response == nil {
                    sender.setOn(false, animated: true)
                }
            })
        case 2:
            guard sender.isOn else { MediumSDKManager.sharedInstance.signOutMedium(completionHandler: { state, response in }); return }
            MediumSDKManager.sharedInstance.doOAuthMedium(controller: self, completionHandler: { state, response in
                if !state {
                    sender.setOn(false, animated: true)
                }
            })
        default: break }
    }
    
}
