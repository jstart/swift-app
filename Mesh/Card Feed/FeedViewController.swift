//
//  FeedViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {

    let cardStack = CardStack().then {
        $0.view.backgroundColor = .white
    }
    let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addChildViewController(cardStack)
        view.addSubview(cardStack.view)
        
        if Keychain.fetchLogin() != nil {
            cardStack.view.constrain(.height, .width, .centerX, .centerY, toItem: view)
        } else {
            cardStack.view.constrain(.width, .centerX, toItem: view)
            cardStack.view.constrain((.height, -46), (.centerY, -23), toItem: view)
            
            let completeProfile = UIView(translates: false).then {
                $0.backgroundColor = Colors.brand
                $0.constrain((.height, 46))
            }
            view.addSubview(completeProfile)
            completeProfile.constrain(.width, .centerX, .bottom, toItem: view)
            
            let label = UILabel(translates: false).then {
                $0.font = .proxima(ofSize: 17)
                $0.textColor = .white
                $0.text = "Complete Your Profile"
            }
            
            completeProfile.addSubview(label)
            
            label.constrain(.leading, constant: 35, toItem: completeProfile)
            label.constrain(.centerY, toItem: completeProfile)
            let image = #imageLiteral(resourceName: "name").withRenderingMode(.alwaysTemplate)
            let profile = UIImageView(image: image).then {
                $0.translates = false
                $0.tintColor = .white
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
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo"))
        
        if Keychain.fetchLogin() != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "sorting"), target: self, action: #selector(sort))
            navigationItem.leftBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "qrCode"), target: self, action: #selector(qr))
        } else {
            navigationController?.navigationBar.isTranslucent = false
            navigationItem.setHidesBackButton(true, animated: true)
        }
        
        if TARGET_OS_SIMULATOR == 1 {
            Client.execute(PositionRequest(lat: 33.978359, lon: -118.368723), completionHandler: { response in
                guard let JSON = response.result.value as? JSONDictionary else { return }
                guard JSON["msg"] == nil else { NotificationCenter.default.post(name: .logout, object: nil); return }
                UserResponse.current = UserResponse(JSON: JSON)
            })
        }

        locationManager.locationUpdate = { loc in
            Client.execute(PositionRequest(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude), completionHandler: { response in
                guard let JSON = response.result.value as? JSONDictionary else { return }
                guard JSON["msg"] == nil else { NotificationCenter.default.post(name: .logout, object: nil); return }
                UserResponse.current = UserResponse(JSON: JSON)
            })
        }
        locationManager.startTracking()
        
        if cardStack.cards?.count != nil || cardStack.cards?.count == cardStack.cardIndex - 1 { return }
        Client.execute(RecommendationsRequest(), completionHandler: { response in
            guard let jsonArray = response.result.value as? JSONArray else { return }
            let array = jsonArray.map({return UserResponse(JSON: $0)})
            self.cardStack.cards = array.map({
                let details = UserDetails(connections: [], experiences: [], educationItems: [], skills: [], events: [])
                return Rec(type: .person, person: Person(user: $0, details: details))
            })
            self.cardStack.addNewCard()
            //self.cardStack.cards?.append(Card(type: .tweet, person: nil))
        })
//        for index in 0..<cardStack.cards?.count {
//            guard let recIds = cardStack.cards?[index].person?.user?._id else {return}
//            Client.execute(ConnectionResponseRequest(recipient: recIds), completionHandler: { response in })
//        }
    }
    
    func profile() { navigationController?.push(CompleteProfileTableViewController(style: .grouped)) }
    
    func sort(){ }
    
    func qr() {
        guard UserResponse.current != nil else { return }
        if CameraManager.authStatus() == .authorized {
            self.present(ScanViewController().withNav()); return
        }
        let alert = AlertViewController([AlertAction(title: "OKAY", backgroundColor: AlertAction.defaultBackground, titleColor: .white, handler: {
            self.dismiss(animated: true, completion: {
                CameraManager.requestAccess(completionHandler: { access in
                    if access { self.present(ScanViewController().withNav()) }
                })
            })
        })], image: #imageLiteral(resourceName: "enableCameraAccess"))
        alert.titleLabel.text = "Camera Access"
        alert.textLabel.text = "We need access to your camera in order to use this feature and scan codes"
        alert.modalPresentationStyle = .overFullScreen
        present(alert)
    }
}
