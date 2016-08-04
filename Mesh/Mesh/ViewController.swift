//
//  ViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var cards : [CardViewController] = [CardViewController()]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //let loading = Loading(viewController: self, activityStyle: ActivityStyle(style: .gray, position: .center))
        //loading.addLoadingView()
        //loading.start()
        
        let card = cards[0]
        if childViewControllers.contains(card) {
            return
        }
        addChildViewController(card)
        view.addSubview(card.view)
        
        NSLayoutConstraint(item: card.view, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant:-60).isActive = true
        NSLayoutConstraint(item: card.view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant:-20).isActive = true
        
        view.centerXAnchor.constraint(equalTo: card.view.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: card.view.centerYAnchor).isActive = true

        card.view.translatesAutoresizingMaskIntoConstraints = false
    }

}
