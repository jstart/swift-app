//
//  CardView.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    convenience init() {
        self.init(frame:CGRect.zero)
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.75
        layer.shadowRadius = 5
        backgroundColor = .white
        layer.cornerRadius = 5
        translates = false
        constrain(.height, constant: 180)
    }

}
