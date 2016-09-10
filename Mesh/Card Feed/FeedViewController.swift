//
//  FeedViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {

    let cardStack = CardStack()
    let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(cardStack)
        view.addSubview(cardStack.view)
        
        cardStack.view.constrain(.height, .width, .centerX, .centerY, toItem: view)
        cardStack.view.translates = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "sorting"), target: self, action: #selector(sort))
        navigationItem.leftBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "qrCode"), target: self, action: #selector(qr))
        
        if TARGET_OS_SIMULATOR == 1 {
            Client.execute(PositionRequest(lat: 33.978359, lon: -118.368723), completionHandler: { response in
                guard let JSON = response.result.value as? JSONDictionary else { return }
                guard JSON["msg"] == nil else { NotificationCenter.default.post(name: .logout, object: nil); return }
                UserResponse.current = UserResponse(JSON: JSON)
            })
        }
        
        Client.execute(UpdatesRequest.fresh(), completionHandler: { response in UpdatesRequest.append(response) })

        locationManager.locationUpdate = { loc in
            Client.execute(PositionRequest(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude), completionHandler: { response in
                guard let JSON = response.result.value as? JSONDictionary else { return }
                guard JSON["msg"] == nil else { NotificationCenter.default.post(name: .logout, object: nil); return }
                UserResponse.current = UserResponse(JSON: JSON)
            })
        }
        locationManager.startTracking()
        
        Client.execute(CardsRequest(), completionHandler: { response in
            guard let JSON = response.result.value as? JSONArray else { return }
            let cards = JSON.map({ return CardResponse(JSON: $0) })
            guard cards.count != 0 else { Client.execute(CardCreateRequest.new(), completionHandler: { response in }); return }
            CardResponse.cards = cards
        })
        
        if cardStack.cards?.count != nil || cardStack.cards?.count == cardStack.cardIndex - 1 { return }
        Client.execute(RecommendationsRequest(), completionHandler: { response in
            guard let jsonArray = response.result.value as? JSONArray else { return }
            let array = jsonArray.map({return UserResponse(JSON: $0)})
            self.cardStack.cards = array.map({
                let details = UserDetails(connections: [], experiences: [], educationItems: [], skills: [], events: [])
                return Card(type: .person, person: Person(user: $0, details: details))
            })
            self.cardStack.addNewCard()
            //                self.cardStack.cards?.append(Card(type: .tweet, person: nil))
        })
//        for index in 0..<cardStack.cards?.count {
//            guard let recIds = cardStack.cards?[index].person?.user?._id else {return}
//            Client.execute(ConnectionRequest(recipient: recIds), completionHandler: { response in })
//        }
    }
    
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
