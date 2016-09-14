//
//  LaunchViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    let card = CardView(height: 380).then {
        $0.constrain((.width, 350))
        $0.layer.shadowOpacity = 0.25
    }

    let getStarted = UIButton(translates: false).then {
        $0.setBackgroundImage(.imageWithColor(Colors.brand), for: .normal)
        $0.titleLabel?.font = .boldProxima(ofSize: 20)
        $0.setTitle("GET STARTED", for: .normal)
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.constrain((.height, 70))
    }
    let signIn = UIButton(translates: false).then {
        $0.setTitle("SIGN IN", for: .normal)
        $0.titleLabel?.font = .boldProxima(ofSize: 20)
        $0.titleLabel?.backgroundColor = Colors.brand
    }
    let legal = UITextView(translates: false).then {
        $0.textColor = .gray
        $0.textAlignment = .center
        $0.attributedText = NSAttributedString(string: "By using Mesh you agree to the Privacy Policy and the Terms of Service", attributes: [:])
        $0.constrain((.height, 44))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .white
        getStarted.addTarget(self, action: #selector(skills), for: .touchUpInside)
        signIn.addTarget(self, action: #selector(phone), for: .touchUpInside)
        
        view.addSubviews(card, getStarted, signIn, legal)
        
        card.constrain(.centerX, toItem: view)
        card.constrain(.centerY, constant: -80, toItem: view)

        getStarted.constrain(.top, constant: 70, toItem: card, toAttribute: .bottom)
        getStarted.constrain(.centerX, toItem: view)
        getStarted.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .leadingMargin)
        getStarted.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .trailingMargin)
        
        signIn.constrain(.centerX, toItem: view)
        signIn.constrain(.top, constant: 5, toItem: getStarted, toAttribute: .bottom)
        
        legal.constrain(.centerX, toItem: view)
        legal.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .leadingMargin)
        legal.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .trailingMargin)
        
        legal.constrain(.top, constant: 5, toItem: signIn, toAttribute: .bottom)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func skills() { navigationController?.push(IndustryViewController()) }
    
    func phone() { navigationController?.push(JoinTableViewController(style: .grouped)) }

}
