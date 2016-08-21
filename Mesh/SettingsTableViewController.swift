//
//  SettingsTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
        return section == 0 ? 3 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = (indexPath.section == 0 && indexPath.row == 0) ? "Edit Profile" : "Logout"
        if (indexPath.section == 0 && indexPath.row == 1)  {
            cell.textLabel?.text = "Upload Photo"
        }
        if (indexPath.section == 0 && indexPath.row == 2)  {
            if UserResponse.currentUser != nil {
                cell.textLabel?.text = "Phone: " + UserResponse.currentUser!.phone_number
                cell.detailTextLabel?.text = "UID: " + UserResponse.currentUser!._id
            } else {
                cell.textLabel?.text = ""
            }
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1:
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                present(picker, animated: true, completion: nil)
                break
            case 0:
                break
            default:
                break
            }
            return
        }
        Client().execute(LogoutRequest(), completionHandler: { response in
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
                
                let vc = JoinTableViewController(style: .grouped)
                UIApplication.shared.delegate!.window??.rootViewController = UINavigationController(rootViewController: vc)
            }
            if (response.result.error != nil) {
                print(response.result.error)
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let data = UIImageJPEGRepresentation(image, 0)
        Client().upload(PhotoRequest(file: data!), completionHandler: { response in
                print("JSON: \(response.result.value)")
                print(response.result.error)
        })
    }

}
