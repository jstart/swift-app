//
//  Extensions.swift
//  Mesh
//
//  Created by Christopher Truman on 8/23/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

extension UIAlertController {
    func addActions(_ actions: UIAlertAction...) {
        for action in actions { addAction(action) }
    }
}

extension UITableView {
    func registerClass(_ cellClasses: AnyClass...) {
        for aClass in cellClasses {
            let string = String(describing: aClass)
            register(aClass, forCellReuseIdentifier: string)
        }
    }
    
    func registerNib(_ cellClasses: AnyClass...) {
        for aClass in cellClasses {
            let string = String(describing: aClass)
            register(UINib(nibName: string, bundle: nil), forCellReuseIdentifier: string)
        }
    }
    
    func dequeue(_ cellClass: AnyClass, indexPath: IndexPath) -> UITableViewCell{
        let string = String(describing: cellClass)
        return dequeueReusableCell(withIdentifier: string, for: indexPath)
    }
}

extension UIView {
    func constrain(_ attributes: NSLayoutAttribute..., relatedBy: NSLayoutRelation = .equal, constant: CGFloat = 0.0, toItem: UIView? = nil, toAttribute: NSLayoutAttribute = .notAnAttribute){
        for attribute in attributes {
            let toAttributeChoice = toAttribute == .notAnAttribute ? attribute : toAttribute
            let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : toAttributeChoice, multiplier: 1.0, constant:constant)
            constraint.isActive = true
        }
    }
    
    func constraint(_ attribute: NSLayoutAttribute, relatedBy: NSLayoutRelation = .equal, constant: CGFloat = 0.0, toItem: UIView? = nil, toAttribute: NSLayoutAttribute = .notAnAttribute) -> NSLayoutConstraint {
        let toAttributeChoice = toAttribute == .notAnAttribute ? attribute : toAttribute
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : toAttributeChoice, multiplier: 1.0, constant:constant)
        constraint.isActive = true
        return constraint
    }
    
    var heightConstraint : NSLayoutConstraint { get { return constraintFor(attribute: .height) } }
    
    var widthConstraint : NSLayoutConstraint { get { return constraintFor(attribute: .width) } }
    
    var topConstraint : NSLayoutConstraint { get { return constraintFor(attribute: .top) } }
    
    var bottomConstraint : NSLayoutConstraint { get { return constraintFor(attribute: .bottom) } }
    
    var leadingConstraint : NSLayoutConstraint { get { return constraintFor(attribute: .leading) } }
    
    var trailingConstraint : NSLayoutConstraint {  get { return constraintFor(attribute: .trailing) } }
    
    func constraintFor(attribute: NSLayoutAttribute, toItem: UIView? = nil) -> NSLayoutConstraint {
        guard let item = toItem else {
            return constraints.filter({ return $0.firstAttribute == attribute }).first!
        }
        return constraints.filter({ return $0.firstAttribute == attribute && $0.firstItem as! UIView == item }).first!
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
}

extension UIViewController {
    func withNav() -> UINavigationController {
        return UINavigationController(rootViewController: self)
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
