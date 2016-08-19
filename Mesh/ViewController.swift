//
//  ViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let cardStack = CardStack()
    let locationManager = LocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.8196078431, green: 0.8196078431, blue: 0.8196078431, alpha: 1)
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "sorting"), style: .plain, target: self, action: #selector(sort))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "qrCode"), style: .plain, target: self, action: #selector(sort))
        view.tintColor = #colorLiteral(red: 0.2, green: 0.7843137255, blue: 0.9960784314, alpha: 1)
        
        let client = Client()
        // AuthRequest(phone_number: "3103479814", password: "password", password_verify: "password", first_name: "chris", last_name: "truman", email: "cleetruman@gmail.com", company: "tinder ventures", profession: "software engineer")
        // AuthRequest(phone_number: "3103479815", password: "password", password_verify: "password", first_name: "john", last_name: "doe", email: "whatever@gmail.com", company: "amazing town", profession: "software engineer")

        // LoginRequest(phone_number: "3103479814", password: "password")
        client.execute(LoginRequest(phone_number: "3103479814", password: "password"), completionHandler: { response in
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
                self.locationManager.startTracking()
            }
            if (response.result.error != nil) {
                print(response.result.error)
            }
            /*client.execute(RecommendationsRequest(), completionHandler: { response in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
                if (response.result.error != nil) {
                    print(response.result.error)
                }
            })*/
        })
        
        if childViewControllers.contains(cardStack) {
            return
        }
        addChildViewController(cardStack)
        cardStack.view.frame = view.frame
        view.addSubview(cardStack.view)
        
        cardStack.view.constrain(.height, .width, .centerX, .centerY, toItem: view)
        cardStack.view.translatesAutoresizingMaskIntoConstraints = false
        
        locationManager.locationUpdate = { location in
            print(location)
            
            client.execute(PositionRequest(lat: location.coordinate.latitude, lon: location.coordinate.longitude, uid: client.uid!), completionHandler: { response in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
                if (response.result.error != nil) {
                    print(response.result.error)
                }
            })
        }
    }

    func sort(){
        
    }
}
