//
//  Constrain.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

extension UIView {
    func constrain(_ attributes : NSLayoutAttribute..., constant : CGFloat = 0.0, toItem : UIView? = nil){
        for attribute in attributes {
            NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : attribute, multiplier: 1.0, constant:constant).isActive = true
        }
    }
}
