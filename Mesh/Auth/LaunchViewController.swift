//
//  LaunchViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController, CardDelegate {
    
    var topCard = LaunchCardViewController()
    let cardStack = CardStack()

    let background = UIImageView(image: #imageLiteral(resourceName: "launchOval")).then {
        $0.translates = false; $0.contentMode = .scaleAspectFill
        $0.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
    }
    let titleLabel = UILabel(translates: false).then {
        $0.textColor = .white; $0.font = .gothamBook(ofSize: 24)
        let attributedString = NSMutableAttributedString(string: "RIPPLE")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(8), range: NSRange(location: 0, length: attributedString.length))
        $0.attributedText = attributedString
        $0.constrain((.height, 26))
    }
    let subtitle = UILabel(translates: false).then {
        $0.text = "A Network Worth Having."; $0.textColor = .white; $0.font = .gothamLight(ofSize: 13)
        $0.constrain((.height, 15))
    }
    let getStarted = UIButton(translates: false).then {
        $0.setBackgroundImage(.imageWithColor(#colorLiteral(red: 0.1058823529, green: 0.1882352941, blue: 0.2666666667, alpha: 1)), for: .normal); $0.contentMode = .center; $0.contentVerticalAlignment = .center
        $0.title = "GET STARTED"; $0.titleLabel?.font = .gothamBook(ofSize: 20)
        $0.layer.cornerRadius = 5; $0.clipsToBounds = true
        $0.constrain((.height, 70))
    }
    let signIn = UIButton(translates: false).then { $0.title = "SIGN IN"; $0.titleColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1); $0.titleLabel?.font = .gothamBook(ofSize: 20) }
    let legal = UITextView(translates: false).then {
        $0.textColor = .gray; $0.textAlignment = .center; $0.isHidden = true
        $0.attributedText = NSAttributedString(string: "By using Mesh you agree to the Privacy Policy and the Terms of Service", attributes: [:])
        $0.constrain((.height, 44))
    }
    var topTimer : Timer?
    var direction = UISwipeGestureRecognizerDirection.right

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .white
        getStarted.addTarget(self, action: #selector(skills), for: .touchUpInside)
        signIn.addTarget(self, action: #selector(phone), for: .touchUpInside)
        view.addSubviews(background, titleLabel, subtitle, getStarted, signIn, legal)
        background.constrain(.width, constant: 5, toItem: view)
        background.constrain(.top, constant: -40, toItem: view)
        background.constrain(.centerX, toItem: view)
        titleLabel.constrain(.top, constant: 50, toItem: view)
        titleLabel.constrain(.centerX, toItem: view)
        subtitle.constrain(.centerX, toItem: view)
        
        addChildViewController(cardStack)
        view.addSubview(cardStack.view)
        titleLabel.constrain(.bottom, constant: 0, toItem: cardStack.view, toAttribute: .top)
        subtitle.constrain(.top, constant: 10, toItem: titleLabel, toAttribute: .bottom)

        cardStack.view.constrain(.bottom, constant: 10, toItem: getStarted, toAttribute: .top)

        cardStack.view.translates = false
        cardStack.view.constrain((.height, 205))
        cardStack.view.constrain((.centerY, -40), toItem: view)
        cardStack.view.constrain(.width, .centerX, toItem: view)

        getStarted.constrain(.centerX, toItem: view)
        getStarted.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .leadingMargin)
        getStarted.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .trailingMargin)
        view.bringSubview(toFront: getStarted)
        
        signIn.constrain(.centerX, toItem: view)
        signIn.constrain(.top, constant: 30, toItem: getStarted, toAttribute: .bottom)
        
        legal.constrain(.centerX, toItem: view)
        legal.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .leadingMargin)
        legal.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: view, toAttribute: .trailingMargin)
        
        legal.constrain(.top, constant: 5, toItem: signIn, toAttribute: .bottom)
        legal.constrain(.bottom, toItem: view)
        addCard(controller: topCard)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        topTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(swipe), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
        topTimer?.invalidate()
    }
    
    func swiped(_ direction: UISwipeGestureRecognizerDirection) {
        self.direction = direction
        topCard = LaunchCardViewController()
        addCard(controller: topCard)
        topTimer?.invalidate()
        topTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(swipe), userInfo: nil, repeats: true)
    }
    
    func addCard(controller: BaseCardViewController) {
        controller.delegate = self
        controller.view.alpha = 0.0
        controller.view.translates = false
        controller.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        controller.view.center = cardStack.view.center
        cardStack.addCard(controller, width: -120)
        cardStack.currentCard = controller
    }
    
    func passCard(_ direction: UISwipeGestureRecognizerDirection) { }
    
    func swiping(percent: CGFloat) { topTimer?.invalidate() }
    
    func swipe() { if direction == .left { cardStack.passCard(.right) } else { cardStack.passCard(.left) } }
    
    func skills() { navigationController?.push(SkillsViewController()) }
    func phone() { navigationController?.push(LoginTableViewController(style: .grouped)) }

}
