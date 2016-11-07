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
    let header = UILabel(translates: false).then {
        $0.textColor = .white; $0.font = .gothamBold(ofSize: 18)
        $0.backgroundColor = Colors.brand
    }
    let content = UILabel(translates: false).then {
        $0.textColor = .white; $0.font = .gothamBook(ofSize: 15)
        $0.numberOfLines = 3
        $0.backgroundColor = Colors.brand
    }
    let button = UIButton(translates: false).then {
        $0.titleLabel?.font = .gothamLight(ofSize: 13); $0.titleColor = .white
    }
    
    var timer : Timer?
    
    init(title: String) {
        super.init(frame: CGRect.zero)
        translates = false
        constrain((.height, 80))
        backgroundColor = Colors.brand
        header.text = title
        button.addTarget(self, action: #selector(pressed), for: .touchUpInside)

        addSubviews(header, content, profile)
        
        profile.constrain((.leading, 15), (.top, 20), toItem: self)
        
        header.constrain((.top, 10), toItem: profile)
        header.constrain(.leading, constant: 15, toItem: profile, toAttribute: .trailing)
        header.constrain(.trailing, constant: -15, toItem: self, toAttribute: .trailing)

        content.constrain((.leading, 0), (.trailing, 0), toItem: header)
        content.constrain(.top, constant: 4, toItem: header, toAttribute: .bottom)
        content.constrain(.bottom, constant: -10, toItem: self, toAttribute: .bottom)

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
        profile.af_setImage(withURL: URL(string: imageURL)!)
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
    
    func dismissWithHandler() { dismiss() }
        
    func dismiss(_ callDismissHandler: Bool = true) {
        UIView.animate(withDuration: 0.2, animations: {
            self.superview?.constraintFor(.bottom, toItem: self)?.constant = 0
            self.superview?.layoutIfNeeded()
            }, completion: { _ in if callDismissHandler { self.dismissed() }; self.removeFromSuperview() })
    }
}
