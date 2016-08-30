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
    let profileImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.constrain(.height, .width, constant: 50)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        guard let smallURL = UserResponse.currentUser?.photos?.small else { return }
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
        return section == 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = (indexPath.section == 0 && indexPath.row == 0) ? "Upload Photo" : "Logout"
        
        if (indexPath.section == 0 && indexPath.row == 1)  {
            if let user = UserResponse.currentUser {
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = "\nName: " + user.fullName()
                cell.detailTextLabel?.text = "UID: " + user._id
            } else {
                cell.textLabel?.text = ""
            }
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
                present(picker, animated: true, completion: nil)
                break
            case 1:
                break
            default:
                break
            }
            return
        }
        Client().execute(LogoutRequest(), completionHandler: { response in
            let vc = JoinTableViewController(style: .grouped)
            UIApplication.shared.delegate!.window??.rootViewController = UINavigationController(rootViewController: vc)
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
            if (response.result.error != nil) {
                print(response.result.error)
            }
        })
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let data = UIImageJPEGRepresentation(image, 1.0)
        Client().upload(PhotoRequest(file: data!), completionHandler: { response in
            print("JSON: \(response.result.value)")
            print(response.result.error)
        })
    }

}
