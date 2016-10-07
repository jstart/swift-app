//
//  AddPhotoViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/15/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import GoogleSignIn

class AddPhotoViewController: UIViewController, GIDSignInUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let profile = UIImageView(translates: false).then {
        $0.layer.cornerRadius = 5; $0.clipsToBounds = true
    }
    let placeholder = CardView(translates: false).then { $0.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1) }
    let addPhoto = UILabel(translates: false).then {
        $0.text = "Add Photo"; $0.font = .boldProxima(ofSize: 20)
    }
    let header = UILabel(translates: false).then {
        $0.text = "Add Profile Picture"; $0.font = .boldProxima(ofSize: 20)
    }
    let text = UILabel(translates: false).then {
        $0.numberOfLines = 0
        $0.text = "We’re almost there! In order to match with people on Mesh, we need you to do this last step to complete your profile."
        $0.font = .proxima(ofSize: 16); $0.textColor = .gray
        $0.textAlignment = .center
    }
    let upload = UIButton(translates: false).then {
        $0.setBackgroundImage(.imageWithColor(Colors.brand), for: .normal)
        $0.setBackgroundImage(.imageWithColor(.lightGray), for: .disabled)
        $0.isEnabled = true
        $0.titleLabel?.font = .boldProxima(ofSize: 20); $0.titleColor = .white
        $0.title = "UPLOAD PHOTO"
        $0.layer.cornerRadius = 5; $0.clipsToBounds = true
        $0.constrain((.height, 70))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Complete Profile"
        
        view.backgroundColor = .white
        
        view.addSubviews(placeholder, header, text, upload)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(photoOptions))
        placeholder.addGestureRecognizer(tap)
        
        placeholder.constrain((.centerX, 0), (.top, 35), (.leading, 55), (.trailing, -55), toItem: view)
        placeholder.addSubview(profile)
        placeholder.constrain(.width, toItem: placeholder, toAttribute: .height)
        placeholder.addSubview(addPhoto)
        addPhoto.constrain(.centerX, .centerY, toItem: placeholder)

        profile.constrain(.centerX, .centerY, .width, .height, toItem: placeholder)
        
        header.constrain(.top, constant: 20, toItem: placeholder, toAttribute: .bottom)
        header.constrain(.centerX, toItem: view)
        
        text.constrain(.top, toItem: header, toAttribute: .bottom)
        text.constrain((.centerX, 0), (.leading, 40), (.trailing, -40), toItem: view)

        upload.addTarget(self, action: #selector(complete), for: .touchUpInside)

        upload.constrain(.centerX, toItem: view)
        upload.constrain(.bottom, constant: -20, toItem: view, toAttribute: .bottom)
        upload.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .leadingMargin)
        upload.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .trailingMargin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func uploadChoice(_ sender: UIAlertAction) {
        if sender.title == "Import from Twitter"{
            TwitterProfile.prefillImage() { response in
                guard let imageURL = response?.image_url else { return }
                self.profile.af_setImage(withURL: URL(string: imageURL )!)
                self.changeToComplete()
            }
        } else if sender.title == "Import from Google" {
            GIDSignIn.sharedInstance().uiDelegate = self
            GoogleProfile.shared.prefillImage() { response in
                guard let imageURL = response?.image_url else { return }
                self.profile.af_setImage(withURL: URL(string: imageURL)!)
                self.changeToComplete()
            }
        } else if sender.title == "Choose from Library" {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            present(picker)
        }
    }
    
    func photoOptions() {
        let twitter = UIAlertAction("Import from Twitter") { sender in self.uploadChoice(sender) }
        let google = UIAlertAction("Import from Google") { sender in self.uploadChoice(sender) }
        let library = UIAlertAction("Choose from Library") { sender in self.uploadChoice(sender) }

        let sheet = UIAlertController.sheet(title: "Add Profile Photo")
        sheet.addActions(twitter, google, library, UIAlertAction.cancel())
        present(sheet)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss()
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        profile.image = image; self.changeToComplete()
    }
    
    func changeToComplete(){
        self.addPhoto.isHidden = true
        upload.setTitle("Complete Profile", for: .normal)
        upload.removeTarget(self, action: #selector(photoOptions), for: .touchUpInside)
        upload.addTarget(self, action: #selector(complete), for: .touchUpInside)
    }
    
    func complete() {
        guard let image = profile.image as UIImage! else { return }
        let data = UIImageJPEGRepresentation(image, 0.1)
        Client.upload(PhotoRequest(file: data!), completionHandler: { response in
            if response.result.value != nil {
                let alert = UIAlertController(title: "Photo Updated", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction.ok() { _ in self.navigationController?.push(SMSViewController()) })
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
