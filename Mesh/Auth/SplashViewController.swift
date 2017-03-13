//
//  SplashViewController.swift
//  Ripple
//
//  Created by Christopher Truman on 11/1/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    weak var finishViewController : UIViewController?
    
    let logo = UIImageView(image: #imageLiteral(resourceName: "icon")).then { $0.translates = false }
    let titleLabel = UILabel(translates:  false).then {
        let attributedString = NSMutableAttributedString(string: "RIPPLE")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(11), range: NSRange(location: 0, length: attributedString.length))
        $0.attributedText = attributedString; $0.textColor = .white
    }
    let transition = FadeTransition()
    let logoView = LogoView(translates: false).then { $0.backgroundColor = .clear; $0.clipsToBounds = false }

    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        
        view.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1098039216, blue: 0.1450980392, alpha: 1)
        view.addSubviews(logo, titleLabel)
        logo.constrain((.centerX, 0), (.centerY, -40), toItem: view)
        titleLabel.constrain(.centerX, constant: 5, toItem: view)
        titleLabel.constrain(.top, constant: 20, toItem: logo, toAttribute: .bottom)
        logo.alpha = 0.0
        titleLabel.alpha = 0.0
        
        //view.addSubview(logoView)
        //logoView.constrain((.centerX, 0), (.centerY, -40), toItem: view)
        //logoView.constrain((.width, 10), (.height, 10), toItem: logo)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logo.fadeIn(duration: 1.0, delay: 0.2) {
            self.titleLabel.fadeIn(duration: 1.0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            self.presentingViewController?.dismiss()
        })
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true; return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false; return transition
    }
    
}
