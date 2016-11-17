//
//  FeedViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import CoreLocation

class FeedViewController: UIViewController {

    let cardStack = CardStack().then { $0.view.backgroundColor = .white }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo"))

        addChildViewController(cardStack)
        view.addSubview(cardStack.view)
        
        if Keychain.fetchLogin() != nil {
            cardStack.view.constrain(.height, .width, .centerX, .centerY, toItem: view)
        } else {
            cardStack.view.constrain(.width, .centerX, toItem: view)
            cardStack.view.constrain((.height, -46), (.centerY, -23), toItem: view)
            
            let completeProfile = UIView(translates: false).then {
                $0.backgroundColor = Colors.brand; $0.constrain((.height, 46))
            }
            view.addSubview(completeProfile)
            completeProfile.constrain(.width, .centerX, .bottom, toItem: view)
            
            let label = UILabel(translates: false).then {
                $0.font = .gothamBook(ofSize: 17); $0.textColor = .white; $0.text = "Complete Your Profile"
            }
            
            completeProfile.addSubview(label)
            
            label.constrain(.leading, constant: 35, toItem: completeProfile)
            label.constrain(.centerY, toItem: completeProfile)
            let image = #imageLiteral(resourceName: "name").withRenderingMode(.alwaysTemplate)
            let profile = UIImageView(image: image).then {
                $0.translates = false; $0.tintColor = .white
            }
            
            completeProfile.addSubview(profile)
            profile.constrain(.centerY, toItem: completeProfile)
            profile.constrain(.leading, constant: 10, toItem: completeProfile)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.profile))
            completeProfile.addGestureRecognizer(tap)
        }
        cardStack.view.translates = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        
        if Keychain.fetchLogin() != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "filtering"), target: self, action: #selector(sort))
            navigationItem.leftBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "qrCode"), target: self, action: #selector(qr))
            Client.execute(ProfileRequest(first_name: UserResponse.current?.first_name)) { response in
                guard let JSON = response.result.value as? JSONDictionary else { return }
                guard JSON["msg"] == nil else { NotificationCenter.default.post(name: .logout, object: nil); return }
                UserResponse.current = UserResponse.create(JSON)
            }
        } else {
            navigationController?.navigationBar.isTranslucent = false
            navigationItem.setHidesBackButton(true, animated: true)
        }
        
        if TARGET_OS_SIMULATOR == 1 {
            LocationManager.currentLocation = CLLocation(latitude: 33.978359, longitude: -118.368723)
            LocationManager.shared.geocoder.reverseGeocodeLocation(LocationManager.currentLocation!, completionHandler: { placemark, error in
                if let placemark = placemark?.first {
                    LocationManager.currentPlacemark = placemark
                }
            })
            Client.execute(PositionRequest(lat: 33.978359, lon: -118.368723))
        }

        LocationManager.locationUpdate = { loc in
            Client.execute(PositionRequest(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude))
        }
        LocationManager.startTracking()
        
        if cardStack.cards?.count != nil || cardStack.cards?.count == cardStack.cardIndex - 1 { return }
        cardStack.animate()
        Client.execute(RecommendationsRequest(), complete: { [weak self] response in
            guard let jsonArray = response.result.value as? JSONArray else { sleep(1); self?.cardStack.stopAnimation(); return }
            self?.cardStack.cards = jsonArray.map({return RecommendationResponse.create($0)})
            sleep(1); self?.cardStack.stopAnimation()
            self?.cardStack.addNewCard()
        })
    }
    
    func profile() {
        presentedViewController?.dismiss()
        navigationController?.push(CompleteProfileTableViewController(style: .grouped))
    }
    
    func sort() { }
    
    func qr() {
        guard UserResponse.current != nil else { return }
        if CameraManager.authStatus() == .authorized {
            self.present(ScanViewController().withNav()); return
        }
        let alert = AlertViewController([AlertAction(title: "OKAY", handler: {
            self.dismiss(animated: true, completion: {
                CameraManager.requestAccess(completionHandler: { access in
                    if access { self.present(ScanViewController().withNav()) }
                })
            })
        })], image: #imageLiteral(resourceName: "enableCameraAccess"))
        let attributedString = NSMutableAttributedString(string: "We need access to your camera in order to use this feature and scan codes")
        let paragraphStyle = NSMutableParagraphStyle(); paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: NSMakeRange(0, attributedString.length))
        alert.textLabel.attributedText = attributedString
        alert.titleLabel.text = "Camera Access"
        alert.modalPresentationStyle = .overFullScreen
        present(alert)
    }
}
