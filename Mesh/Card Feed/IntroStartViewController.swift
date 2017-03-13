//
//  IntroStartViewController.swift
//  Ripple
//
//  Created by Christopher Truman on 2/1/17.
//  Copyright © 2017 Tinder. All rights reserved.
//

import UIKit

class IntroStartViewController: UIViewController, UIViewControllerTransitioningDelegate {

    let close = UIButton(translates: false).then {
        $0.setImage(#imageLiteral(resourceName: "closeIntro"), for: .normal)
    }
    let introduceLabel = UILabel(translates: false).then {
        $0.text = "Introduce me to..."
        $0.textColor = .white
        $0.font = .gothamLight(ofSize: 25)
    }
    
    let gradientButton = UIButton(translates: false).then {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.brand.cgColor
        $0.layer.cornerRadius = 5
        $0.constrain(.width, .height, constant: 75)
    }
    let gradientButton1 = UIButton(translates: false).then {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.brand.cgColor
        $0.layer.cornerRadius = 5
        $0.constrain(.width, .height, constant: 75)
    }
    let gradientButton2 = UIButton(translates: false).then {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.brand.cgColor
        $0.layer.cornerRadius = 5
        $0.constrain(.width, .height, constant: 75)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .custom

        view.backgroundColor = .black
        close.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        
        view.addSubview(close)
        close.constrain(.top, constant: 25, toItem: view)
        close.constrain(.right, constant: -20, toItem: view)
        
        let stackView = UIStackView(arrangedSubviews: [gradientButton, gradientButton1, gradientButton2])
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translates = false
        
        view.addSubview(stackView)
        stackView.constrain(.centerX, .centerY, toItem: view)
        stackView.constrain(.height, constant: 75)
        
        view.addSubview(introduceLabel)
        
        introduceLabel.constrain(.bottom, constant: -25, toItem: stackView, toAttribute: .top)
        introduceLabel.constrain(.centerX, toItem: stackView)
    }
    
    func closeView() {
        presentingViewController?.dismiss()
    }
    
}
