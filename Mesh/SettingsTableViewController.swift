//
//  SettingsTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let profileImage = UIImageView(translates: false).then {
        $0.constrain(.height, .width, constant: 50)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        guard let smallURL = UserResponse.current?.photos?.small else { return }
        profileImage.af_setImage(withURL: URL(string: smallURL)!)
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
        cell.textLabel?.text = (indexPath.section == 0 && indexPath.row == 0) ? "Upload Photo" : "Logout"
        
        if (indexPath.section == 0 && indexPath.row == 1)  {
            if let user = UserResponse.current {
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = "\nName: " + user.fullName()
                cell.detailTextLabel?.text = "UID: " + user._id
            } else {
                cell.textLabel?.text = ""
            }
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "Edit Profile"
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                present(picker)
                break
            case 1: break
            case 2:
                navigationController?.push(EditTableViewController(style: .grouped))
                break
            default: break
            }
            return
        }
        Client.execute(LogoutRequest(), completionHandler: { response in
            let vc = JoinTableViewController(style: .grouped)
            UIApplication.shared.delegate!.window??.rootViewController = UINavigationController(rootViewController: vc)
        })
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss()
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        let data = UIImageJPEGRepresentation(image, 0.1)
        Client.upload(PhotoRequest(file: data!), completionHandler: { response in
            if response.result.value != nil {
                let alert = UIAlertController(title: "Photo Updated", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction("Ok", style: .cancel))
                self.present(alert)
            }
            else {
                let alert = UIAlertController(title: "Error", message: response.result.error?.localizedDescription ?? "Unknown Error", preferredStyle: .alert)
                alert.addAction(UIAlertAction("Ok", style: .cancel))
                self.present(alert)
            }
        })
    }

}
