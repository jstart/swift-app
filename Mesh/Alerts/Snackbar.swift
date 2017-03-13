//
//  Snackbar.swift
//  Mesh
//
//  Created by Christopher Truman on 9/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class Snackbar : UIView {
    
    var snackDuration = 3.0
    var persist = false
    var handler = { return false }
    var dismissed = {}
    let message = UILabel(translates: false).then {
        $0.textColor = .white; $0.font = .gothamBook(ofSize: 14)
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
        constrain((.height, 43))
        backgroundColor = Colors.brand
        
        button.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        message.text = title
        addSubviews(message, button)
        
        message.constrain((.leading, 15), (.top, 6), (.bottom, -6), toItem: self)
        message.constrain(.trailing, constant: 5, toItem: button)

        button.constrain((.trailing, -15), toItem: self)
        button.constrain(.top, .bottom, constant: 2, toItem: self)
    }
    
    convenience init(title: String, buttonTitle: String = "", buttonHandler: @escaping (() -> Bool) = { return false }, duration: TimeInterval = 3.0, dismissed: @escaping (() -> Void) = {}, showUntilDismissed: Bool = false) {
        self.init(title: title)
        button.setTitle(buttonTitle, for: .normal)
        handler = buttonHandler
        snackDuration = duration
        persist = showUntilDismissed
        self.dismissed = dismissed
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func presentIn(_ view: UIView?) {
        guard let view = view else { return }
        view.addSubview(self)
        constrain(.leading, .trailing, toItem: view)
        constrain(.top, toItem: view, toAttribute: .bottom)
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            view.constraintFor(.top, toItem: self)?.constant = -self.frame.size.height
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
            self.superview?.constraintFor(.top, toItem: self)?.constant = 0
            self.superview?.layoutIfNeeded()
            }, completion: { _ in if callDismissHandler { self.dismissed() }; self.removeFromSuperview() })
    }
}
