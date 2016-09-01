//
//  AddCardView.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class AddCardView: CardView {
    
    let add = UIImageView().then {
        $0.image = #imageLiteral(resourceName: "addCard")
    }
    
    let text = UILabel().then {
        $0.textColor = .lightGray
    }
    var handler: (() -> Void)?
    
    convenience init(touchHandler: (() -> Void)) {
        self.init()
        handler = touchHandler
        text.text = "Add Card"
        let stackView = UIStackView(arrangedSubviews: [add, text])
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.constrain(.centerX, .centerY, .height, toItem: self)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tapGesture)
    }
    
    func tap() {
        handler?()
    }
    
}

