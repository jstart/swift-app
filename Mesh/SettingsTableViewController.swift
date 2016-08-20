//
//  SettingsTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Profile" : "Logout"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = (indexPath.section == 0 && indexPath.row == 0) ? "Edit Profile" : "Logout"
        if (indexPath.section == 0 && indexPath.row == 1)  {
            cell.textLabel?.text = "Phone: " + UserResponse.currentUser!.phone_number
            cell.detailTextLabel?.text = "UID: " + UserResponse.currentUser!._id
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Client().execute(LogoutRequest(), completionHandler: { response in
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
            if (response.result.error != nil) {
                print(response.result.error)
            }
        })
    }

}
