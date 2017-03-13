//
//  Colors.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

struct Colors {
    static var brand = #colorLiteral(red: 0.05490196078, green: 0.2, blue: 0.4039215686, alpha: 1)
    
    static var gradient : CAGradientLayer {
        return CAGradientLayer().then { $0.colors = [#colorLiteral(red: 0.05490196078, green: 0.2, blue: 0.4039215686, alpha: 1).cgColor, #colorLiteral(red: 0.1843137255, green: 0.3019607843, blue: 0.4705882353, alpha: 1).cgColor]; $0.startPoint = CGPoint(x: 0, y: 0); $0.endPoint = CGPoint(x: 1,y: 1); $0.masksToBounds = true }
    }
}
