//
//  AddCardView.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class AddCardView: CardView {
    
    let add = UIImageView(image: #imageLiteral(resourceName: "addCard"))
    let text = UILabel().then {
        $0.font = .proxima(ofSize: 17)
        $0.textColor = .lightGray
    }
    var handler = {}
    
    convenience init(touchHandler: @escaping (() -> Void)) {
        self.init()
        handler = touchHandler
        text.text = "Add Card"
        
        constrain((.height, 180))

        let stackView = UIStackView(arrangedSubviews: [add, text])
        addSubview(stackView)
        
        stackView.translates = false
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.constrain(.centerX, .centerY, .height, toItem: self)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tapGesture)
    }
    
    func tap() { handler() }
    
}

