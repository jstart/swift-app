//
//  Colors.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

struct Colors {
    static var brand = #colorLiteral(red: 0.1647058824, green: 0.7098039216, blue: 0.9960784314, alpha: 1)
    
    static var gradient : CAGradientLayer {
        return CAGradientLayer().then { $0.colors = [#colorLiteral(red: 0.2, green: 0.7843137255, blue: 0.9960784314, alpha: 1).cgColor, #colorLiteral(red: 0.1254901961, green: 0.6549019608, blue: 0.9568627451, alpha: 1).cgColor]; $0.startPoint = CGPoint(x: 0, y: 0); $0.endPoint = CGPoint(x: 1,y: 1); $0.masksToBounds = true }
    }
}
