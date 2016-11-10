//
//  TopAlert.swift
//  Mesh
//
//  Created by Christopher Truman on 9/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class TopAlert : UIView {
    
    var snackDuration = 3.0
    var persist = false
    var handler = { return false }
    var dismissed = {}
    let profile = UIImageView(translates: false).then {
        $0.layer.cornerRadius = 5; $0.constrain(.width, .height, constant: 40)
        $0.image = .imageWithColor(.gray); $0.clipsToBounds = true
    }
    let headerContainer = UIView(translates: false).then { $0.backgroundColor = Colors.brand; $0.constrain((.height, 80)) }
    let header = UILabel(translates: false).then {
        $0.textColor = .white; $0.font = .gothamBold(ofSize: 18)
        $0.backgroundColor = Colors.brand
    }
    let content = UILabel(translates: false).then {
        $0.textColor = .white; $0.font = .gothamBook(ofSize: 15)
        $0.numberOfLines = 0
        $0.backgroundColor = Colors.brand
    }
    let button = UIButton(translates: false).then {
        $0.titleLabel?.font = .gothamLight(ofSize: 13); $0.titleColor = .white
    }
    var buttons = [UIButton]()
    var actions = [AlertAction]() {
        didSet {
            for (index, action) in actions.enumerated() {
                let button = UIButton(translates: false).then {
                    $0.title = action.title; $0.titleColor = action.titleColor
                    $0.titleLabel?.font = .gothamBook(ofSize: 15)
                    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
                    if let icon = action.icon { $0.image = icon }
                    $0.setBackgroundImage(.imageWithColor(action.backgroundColor), for: .normal)
                    $0.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
                    $0.constrain(.height, constant: 50)
                }
                addSubview(button)
                if actions.count == 1 {
                    button.constrain(.width, toItem: self)
                    button.constrain(.leading, .trailing, .bottom, toItem: self)
                    button.constrain(.top, toItem: headerContainer, toAttribute: .bottom)
                } else {
                    if index == 0 {
                        button.constrain(.leading, .bottom, toItem: self)
                        button.constrain(.top, toItem: headerContainer, toAttribute: .bottom)
                    } else {
                        button.constrain(.leading, toItem: buttons[0], toAttribute: .trailing)
                        button.constrain(.width, toItem: buttons[0])
                        button.constrain(.trailing, .bottom, toItem: self)
                        button.constrain(.top, toItem: headerContainer, toAttribute: .bottom)
                    }
                }
                
                buttons.append(button)
            }
        }
    }

    var timer : Timer?
    
    init(title: String) {
        super.init(frame: CGRect.zero)
        translates = false
        backgroundColor = Colors.brand
        header.text = title
        button.addTarget(self, action: #selector(pressed), for: .touchUpInside)

        addSubview(headerContainer)
        headerContainer.constrain(.leading, .trailing, .top, toItem: self)
        headerContainer.addSubviews(header, content, profile)
        
        profile.constrain((.leading, 15), (.top, 20), toItem: headerContainer)
        
        header.constrain((.top, 10), toItem: profile)
        header.constrain(.leading, constant: 15, toItem: profile, toAttribute: .trailing)
        header.constrain(.trailing, constant: -15, toItem: headerContainer, toAttribute: .trailing)

        content.constrain((.leading, 0), (.trailing, 0), toItem: header)
        content.constrain(.top, constant: 4, toItem: header, toAttribute: .bottom)
        content.constrain(.bottom, constant: -10, toItem: headerContainer, toAttribute: .bottom)

//        button.constrain((.trailing, -15), toItem: self)
//        button.constrain(.top, .bottom, constant: 2, toItem: self)
    }
    
    convenience init(title: String, content: String = "", imageURL: String = "", buttonHandler : @escaping (() -> Bool) = { return false }, duration: TimeInterval = 3.0, dismissed: @escaping (() -> Void) = {}, showUntilDismissed: Bool = false) {
        self.init(title: title)
//        button.setTitle(buttonTitle, for: .normal)
        handler = buttonHandler
        snackDuration = duration
        persist = showUntilDismissed
        self.dismissed = dismissed
        self.content.text = content
        profile.af_setImage(withURL: URL(string: imageURL)!, imageTransition: .crossDissolve(0.2))
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func presentIn(_ view: UIView?) {
        guard let view = view else { return }
        view.addSubview(self)
        constrain(.leading, .trailing, toItem: view)
        constrain(.bottom, toItem: view, toAttribute: .top)
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            view.constraintFor(.bottom, toItem: self)?.constant = self.frame.size.height
            view.layoutIfNeeded()
            }, completion: { _ in
                guard !self.persist else { return }
                self.timer = Timer.scheduledTimer(timeInterval: self.snackDuration, target: self, selector: #selector(self.dismissWithHandler), userInfo: nil, repeats: false)
        })
    }
    
    func pressed() { if handler() { dismiss(false) } }
    func buttonPress(sender: UIButton) { for action in actions {  if sender.titleLabel?.text == action.title { action.handler() } } }

    func dismissWithHandler() { dismiss() }
        
    func dismiss(_ callDismissHandler: Bool = true) {
        UIView.animate(withDuration: 0.2, animations: {
            self.superview?.constraintFor(.bottom, toItem: self)?.constant = 0
            self.superview?.layoutIfNeeded()
            }, completion: { _ in if callDismissHandler { self.dismissed() }; self.removeFromSuperview() })
    }
}
