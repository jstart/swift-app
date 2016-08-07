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
        //let loading = Loading(viewController: self, activityStyle: ActivityStyle(style: .gray, position: .center))
        //loading.addLoadingView()
        //loading.start()
        
        if childViewControllers.contains(cardStack) {
            return
        }
        addChildViewController(cardStack)
        cardStack.view.frame = view.frame
        view.addSubview(cardStack.view)
        
        NSLayoutConstraint(item: cardStack.view, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant:0).isActive = true
        NSLayoutConstraint(item: cardStack.view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant:0).isActive = true
        
        view.centerXAnchor.constraint(equalTo: cardStack.view.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: cardStack.view.centerYAnchor).isActive = true
        
        cardStack.view.translatesAutoresizingMaskIntoConstraints = false
    }

}
