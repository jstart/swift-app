//
//  Extensions.swift
//  Mesh
//
//  Created by Christopher Truman on 8/23/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

extension UITableView {
    func register(_ cellClasses: AnyClass...) {
        for aClass in cellClasses {
            let string = String(describing: aClass)
            register(UINib(nibName: string, bundle: nil), forCellReuseIdentifier: string)
        }
    }
}

extension UIView {
    func constrain(_ attributes : NSLayoutAttribute..., relatedBy: NSLayoutRelation = .equal, constant : CGFloat = 0.0, toItem : UIView? = nil){
        for attribute in attributes {
            let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : attribute, multiplier: 1.0, constant:constant)
            constraint.isActive = true
        }
    }
    
    func constraints(_ attributes : NSLayoutAttribute..., relatedBy: NSLayoutRelation = .equal, constant : CGFloat = 0.0, toItem : UIView? = nil) -> [NSLayoutConstraint]{
        var constraints = [NSLayoutConstraint]()
        for attribute in attributes {
            let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : attribute, multiplier: 1.0, constant:constant)
            constraint.isActive = true
            constraints.append(constraint)
        }
        return constraints
    }
    
    func addSubviews(_ views: [UIView]) {
        views.forEach {
            self.addSubview($0)
        }
    }

}

extension Int {
    func perform(_ closure: () -> Void) {
        (0..<self).forEach { _ in
            closure()
        }
    }
    
    func performIndex(_ closure: @escaping (Int) -> Void) {
        (0..<self).forEach { index in
            closure(index)
        }
    }
}

protocol Then {}

extension Then where Self: AnyObject {
    func then(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Then {}
