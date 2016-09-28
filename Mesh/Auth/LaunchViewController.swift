//
//  LaunchViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    let topCard = LaunchCardView(""), bottomCard = LaunchCardView("")

    let logo = UIImageView(image: #imageLiteral(resourceName: "logo_large")).then {
        $0.translates = false
    }
    let subtitle = UILabel(translates: false).then {
        $0.text = "Tinder for Business"
        $0.textColor = .black
        $0.font = .boldProxima(ofSize: 20)
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
        $0.setTitleColor(Colors.brand, for: .normal)
    }
    let legal = UITextView(translates: false).then {
        $0.textColor = .gray
        $0.textAlignment = .center
        $0.attributedText = NSAttributedString(string: "By using Mesh you agree to the Privacy Policy and the Terms of Service", attributes: [:])
        $0.constrain((.height, 44))
    }
    var topTimer : Timer?
    var center : CGPoint?
    
    var top = true

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .white
        getStarted.addTarget(self, action: #selector(skills), for: .touchUpInside)
        signIn.addTarget(self, action: #selector(phone), for: .touchUpInside)
        view.addSubviews(logo, subtitle, bottomCard, topCard, getStarted, signIn, legal)
        
        logo.constrain((.leading, 100), (.trailing, -100), (.top, 35), toItem: view)
        logo.constrain(.bottom, constant: -10, toItem: subtitle, toAttribute: .top)
        
        subtitle.constrain(.centerX, toItem: view)
        subtitle.constrain(.bottom, constant: -25, toItem: topCard, toAttribute: .top)
        
        topCard.constrain(.centerX, toItem: view)
        topCard.constrain((.width, -120), (.centerY, -40), toItem: view)
        bottomCard.constrain(.centerX, toItem: view)
        bottomCard.constrain((.width, -120), (.centerY, -40), toItem: view)
//      card.constrain(.height, toItem: card, toAttribute: .width, multiplier: 760/690)

//      getStarted.constrain(.top, constant: 70, toItem: card, toAttribute: .bottom)
        getStarted.constrain(.centerX, toItem: view)
        getStarted.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .leadingMargin)
        getStarted.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .trailingMargin)
        
        signIn.constrain(.centerX, toItem: view)
        signIn.constrain(.top, constant: 5, toItem: getStarted, toAttribute: .bottom)
        
        legal.constrain(.centerX, toItem: view)
        legal.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .leadingMargin)
        legal.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .trailingMargin)
        
        legal.constrain(.top, constant: 5, toItem: signIn, toAttribute: .bottom)
        legal.constrain(.bottom, toItem: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        topTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(swipe), userInfo: nil, repeats: true)
        center = CGPoint(x: view.center.x, y: view.center.y - 40)
        
        topCard.center = center!; topCard.transform = .identity
        bottomCard.center = center!; bottomCard.transform = .identity
        top = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        topTimer?.invalidate()
    }
    
    func swipe() {
        if top {
            view.bringSubview(toFront: bottomCard)
            topCard.center = center!
            topCard.transform = .identity
            topCard.transform = topCard.transform.scaledBy(x: 0.5, y: 0.5)
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.75, animations: {
                self.bottomCard.center = CGPoint(x: -300, y: 100 + self.bottomCard.center.y)
                self.bottomCard.transform = self.bottomCard.transform.rotated(by: (-45 * CGFloat(M_PI)) / 180)
                self.topCard.transform = .identity
            })
        }else {
            view.bringSubview(toFront: topCard)
            bottomCard.center = center!
            bottomCard.transform = .identity
            bottomCard.transform = bottomCard.transform.scaledBy(x: 0.5, y: 0.5)
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.75, animations: {
                self.topCard.center = CGPoint(x: self.view.frame.size.width + 300, y: 100 + self.topCard.center.y)
                self.topCard.transform = self.topCard.transform.rotated(by: (45 * CGFloat(M_PI)) / 180)
                self.bottomCard.transform = .identity
            })
        }
        top = !top
    }
    
    func skills() { navigationController?.push(SkillsViewController()) }
    func phone() { navigationController?.push(JoinTableViewController(style: .grouped)) }

}
