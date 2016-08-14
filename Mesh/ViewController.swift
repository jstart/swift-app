//
//  ViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var cardStack = CardStack()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let client = Client()
        client.execute(LoginRequest(phone_number: "3103479814", password: "password"), completionHandler: { response in
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
            if (response.result.error != nil) {
                print(response.result.error)
            }
            client.execute(UpdatesRequest(last_update: 0), completionHandler: { response in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
                if (response.result.error != nil) {
                    print(response.result.error)
                }
            })
        })
        
        if childViewControllers.contains(cardStack) {
            return
        }
        addChildViewController(cardStack)
        cardStack.view.frame = view.frame
        view.addSubview(cardStack.view)
        
        cardStack.view.constrain(.height, toItem: view)
        cardStack.view.constrain(.width, toItem: view)
        
        cardStack.view.constrain(.centerX, toItem: view)
        cardStack.view.constrain(.centerY, toItem: view)
        
        cardStack.view.translatesAutoresizingMaskIntoConstraints = false
    }

}
