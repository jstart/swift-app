//
//  LaunchCardView.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class LaunchCardView: CardView {
    
    let bottom = UIView(translates: false).then {
        $0.backgroundColor = .white
        $0.constrain(.height, toItem: $0, toAttribute: .width, multiplier: 200/615)
    }
    let top = UIImageView(translates: false).then {
        $0.image = #imageLiteral(resourceName: "discover")
        $0.contentMode = .scaleAspectFit
    }
    let header = UILabel().then {
        $0.text = "Network"
        $0.font = .boldProxima(ofSize: 20)
        $0.textColor = .darkGray
    }
    let text = UILabel().then {
        $0.text = "Connect and chat with people in your industry"
        $0.font = .proxima(ofSize: 16); $0.textColor = .lightGray
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
    }
    
    convenience init(_ string: String) {
        self.init()
        backgroundColor = #colorLiteral(red: 0.7254901961, green: 0.9019607843, blue: 1, alpha: 1)
        layer.shadowOpacity = 0.20
        layer.shadowRadius = 5
        translates = false
        constrain((.height, 305))
        
        addSubviews(top, bottom)
        top.constrain(.centerX, toItem: self)
        top.constrain(.bottom, constant: -30, toItem: bottom, toAttribute: .top)
        top.constrain((.top, 40), (.leading, 25), (.trailing, -25), toItem: self)
        
        bottom.constrain(.bottom, .leading, .trailing, toItem: self)
        
        let stack = UIStackView(header, text, axis: .vertical)
        stack.translates = false
        stack.alignment = .center
        bottom.addSubview(stack)
        stack.constrain(.centerX, .centerY, .leadingMargin, .trailingMargin, toItem: bottom)
        stack.constrain((.bottom, -5), toItem: bottom)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottom.round(corners: [.bottomLeft, .bottomRight])
    }
    
}
