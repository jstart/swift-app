//
//  OutlineView.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class OutlineView: UIView {
    
    static func qrCorner(_ transform: CGAffineTransform) -> UIImageView {
        return UIImageView(image: #imageLiteral(resourceName: "qrCorner")).then {
            $0.translates = false
            $0.constrain((.width, 40), (.height, 40))
            $0.transform = transform
        }
    }
    
    convenience init() {
        self.init(frame:CGRect.zero)
        translates = false
        backgroundColor = .clear
        constrain(.height, constant: 190)
        
        let image = UIView(translates: false).then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 5
            $0.alpha = 0.35
            $0.constrain(.width, .height, constant: 100)
        }
        
        addSubview(image)
        image.constrain((.leading, 25), (.centerY, 0), toItem: self)
        
        let name = UIView(translates: false).then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 5
            $0.alpha = 0.35
            $0.constrain((.width, 120), (.height, 20))
        }
        
        addSubview(name)
        name.constrain(.leading, constant: 10, toItem: image, toAttribute: .trailing)
        name.constrain(.centerY, toItem: image)
        
        let title = UIView(translates: false).then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 5
            $0.alpha = 0.35
            $0.constrain((.height, 20))
        }
        
        addSubview(title)
        title.constrain(.leading, toItem: name)
        title.constrain((.trailing, -50), toItem: self)
        title.constrain(.top, constant: 5, toItem: name, toAttribute: .bottom)
        
        let cornerUL = OutlineView.qrCorner(.identity),
            cornerBL = OutlineView.qrCorner(.init(rotationAngle: -90 * CGFloat(M_PI)/180)),
            cornerUR = OutlineView.qrCorner(.init(rotationAngle: 90 * CGFloat(M_PI)/180)),
            cornerBR = OutlineView.qrCorner(.init(rotationAngle: 180 * CGFloat(M_PI)/180))
        addSubviews(cornerUL, cornerBL, cornerUR, cornerBR)
        
        cornerUL.constrain(.leading, .top, toItem: self)
        cornerBL.constrain(.leading, .bottom, toItem: self)
        cornerUR.constrain(.trailing, .top, toItem: self)
        cornerBR.constrain(.trailing, .bottom, toItem: self)
    }

}
