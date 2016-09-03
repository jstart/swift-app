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
    var handler : (() -> Void)?
    
    let message = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 14)
        $0.numberOfLines = 3
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let button = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var timer : Timer?
    
    init(title: String) {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
        
        button.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        message.text = title
        addSubviews(message, button)
        
        message.constrain(.leading, constant: 15, toItem: self)
        message.constrain(.trailing, constant: 5, toItem: button)
        message.constrain(.top, constant: 6, toItem: self)
        message.constrain(.bottom, constant: -6, toItem: self)

        button.constrain(.trailing, constant: -15, toItem: self)
        button.constrain(.top, .bottom, constant: 2, toItem: self)
    }
    
    convenience init(title: String, buttonTitle: String = "", buttonHandler : (() -> Void), duration: TimeInterval = 3.0, showUntilDismissed: Bool = false) {
        self.init(title: title)
        button.setTitle(buttonTitle, for: .normal)
        handler = buttonHandler
        snackDuration = duration
        persist = showUntilDismissed
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentIn(view: UIView) {
        view.addSubview(self)
        constrain(.leading, .trailing, toItem: view)
        constrain(.top, toItem: view, toAttribute: .bottom)
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            view.constraintFor(.top, toItem: self).constant = -self.frame.size.height
            view.layoutIfNeeded()
            }, completion: { _ in
                guard !self.persist else { return }
                self.timer = Timer.scheduledTimer(timeInterval: self.snackDuration, target: self, selector: #selector(self.dismiss), userInfo: nil, repeats: false)
        })
    }
    
    func pressed() { handler?() }
    
    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.superview?.constraintFor(.top, toItem: self).constant = 0
            self.superview?.layoutIfNeeded()
            }, completion: { _ in
                self.removeFromSuperview()
        })
    }
}
