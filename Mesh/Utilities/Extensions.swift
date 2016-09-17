//
//  Extensions.swift
//  Mesh
//
//  Created by Christopher Truman on 8/23/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

extension String {
    private var qrImage: CIImage? {
        let textData = data(using: .isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(textData, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        
        return filter?.outputImage
    }
    
    func qrImage(withSize size: CGSize, foreground: UIColor = .black, background: UIColor = .white) -> UIImage? {
        return qrImage?.scaledWithSize(size).colored(withForeground: foreground, background: background)?.uiImage
    }
}

private extension CIImage {
    var uiImage: UIImage? { return UIImage(ciImage: self) }
    
    func scaledWithSize(_ size: CGSize) -> CIImage {
        let scaleX = size.width / extent.size.width
        let scaleY = size.height / extent.size.height
        
        return applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
    }
    
    func colored(withForeground foreground: UIColor, background: UIColor) -> CIImage? {
        let foregroundCoreColor = CIColor(uiColor: foreground)
        let backgroundCoreColor = CIColor(uiColor: background)
        
        let colorFilter = CIFilter(name: "CIFalseColor", withInputParameters: [
            "inputImage": self,
            "inputColor0":foregroundCoreColor,
            "inputColor1":backgroundCoreColor
            ])
        
        return colorFilter?.outputImage
    }
}

private extension CIColor {
    convenience init(uiColor: UIColor) {
        let foregroundColorRef = uiColor.cgColor
        let foregroundColorString = CIColor(cgColor: foregroundColorRef).stringRepresentation
        
        self.init(string: foregroundColorString)
    }
}

extension UIMotionEffectGroup {
    convenience init(_ motionEffects: [UIMotionEffect]) {
        self.init()
        self.motionEffects = motionEffects
    }
}

extension UIMotionEffect {
    
    class func twoAxesTilt(strength: Float) -> UIMotionEffect {
        func relativeValue(_ isMax: Bool, type: UIInterpolatingMotionEffectType) -> NSValue {
            var transform = CATransform3DIdentity
            transform.m34 = (1.0 * CGFloat(strength)) / 2000.0
            
            let axisValue: CGFloat
            if type == .tiltAlongVerticalAxis {
                // transform vertically
                axisValue = isMax ? -1.0 : 1.0
                transform = CATransform3DRotate(transform, axisValue * CGFloat(M_PI_4), 1, 0, 0)
            } else {
                // transform horizontally
                axisValue = isMax ? 1.0 : -1.0
                transform = CATransform3DRotate(transform, axisValue * CGFloat(M_PI_4), 0, 1, 0)
            }
            return NSValue(caTransform3D: transform)
        }
        
        // create motion for specified `type`.
        func motion(_ type: UIInterpolatingMotionEffectType) -> UIInterpolatingMotionEffect {
            let motion = UIInterpolatingMotionEffect(keyPath: "layer.transform", type: type)
            motion.minimumRelativeValue = relativeValue(false, type: type)
            motion.maximumRelativeValue = relativeValue(true, type: type)
            return motion
        }
        
        // create group of horizontal and vertical tilt motions
        let group = UIMotionEffectGroup([motion(.tiltAlongHorizontalAxis), motion(.tiltAlongVerticalAxis)])
        return group
    }
}

extension UIImage {
    static func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

extension UIFont {
    static func proxima(ofSize: CGFloat) -> UIFont { return UIFont(name: "ProximaNovaSoft-Medium", size: ofSize)! }
    static func boldProxima(ofSize: CGFloat) -> UIFont { return UIFont(name: "ProximaNovaSoft-Semibold", size: ofSize)! }
    static func semiboldProxima(ofSize: CGFloat) -> UIFont { return UIFont(name: "ProximaNovaSoft-Semibold", size: ofSize)! }
    static func regularProxima(ofSize: CGFloat) -> UIFont { return UIFont(name: "ProximaNovaSoft-Regular", size: ofSize)! }
}

extension UIAlertController {
    func addActions(_ actions: UIAlertAction...) { for action in actions { addAction(action) } }
    static func sheet() -> UIAlertController { return UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet) }
}

extension UIAlertAction {
    convenience init(_ title: String, style: UIAlertActionStyle = .default, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        self.init(title: title, style: style, handler: handler)
    }
    static func cancel(handler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertAction { return UIAlertAction("Cancel", style: .cancel, handler: handler) }
    static func ok(handler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertAction { return UIAlertAction("OK", style: .cancel, handler: handler) }
}

extension UIBarButtonItem {
    convenience init(_ image: UIImage, style: UIBarButtonItemStyle = .plain, target: AnyObject, action: Selector) {
        self.init(image: image, style: .plain, target: target, action: action)
    }
}

extension UICollectionView {
    func registerClass(_ cellClasses: AnyClass...) {
        for aClass in cellClasses { register(aClass, forCellWithReuseIdentifier: String(describing: aClass)) }
    }
    
    func registerNib(_ cellClasses: AnyClass...) {
        for aClass in cellClasses {
            let string = String(describing: aClass)
            register(UINib(nibName: string, bundle: nil), forCellWithReuseIdentifier: string)
        }
    }
    
    func dequeue<T: UICollectionViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T{
        let string = String(describing: cellClass)
        return dequeueReusableCell(withReuseIdentifier: string, for: indexPath) as! T
    }
}

extension UITableView {
    func registerClass(_ cellClasses: AnyClass...) {
        for aClass in cellClasses { register(aClass, forCellReuseIdentifier: String(describing: aClass)) }
    }
    
    func registerNib(_ cellClasses: AnyClass...) {
        for aClass in cellClasses {
            let string = String(describing: aClass)
            register(UINib(nibName: string, bundle: nil), forCellReuseIdentifier: string)
        }
    }
    
    func dequeue<T: UITableViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T{
        let string = String(describing: cellClass)
        return dequeueReusableCell(withIdentifier: string, for: indexPath) as! T
    }
}

extension UIView {
    var translates: Bool {
        get { return translatesAutoresizingMaskIntoConstraints }
        set { translatesAutoresizingMaskIntoConstraints = newValue }
    }
    
    convenience init(translates: Bool) {
        self.init(); self.translates = translates
    }
    
    func constrain(_ constants : (attr: NSLayoutAttribute, const: CGFloat)..., toItem: UIView? = nil){
        for constantPair in constants {
            let constraint = NSLayoutConstraint(item: self, attribute: constantPair.attr, relatedBy: .equal, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : constantPair.attr, multiplier: 1.0, constant:constantPair.const)
            constraint.isActive = true
        }
    }
    
    func constrain(_ attributes: NSLayoutAttribute..., relatedBy: NSLayoutRelation = .equal, constant: CGFloat = 0.0, toItem: UIView? = nil, toAttribute: NSLayoutAttribute = .notAnAttribute, multiplier: CGFloat = 1.0){
        for attribute in attributes {
            let toAttributeChoice = toAttribute == .notAnAttribute ? attribute : toAttribute
            let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : toAttributeChoice, multiplier: multiplier, constant:constant)
            constraint.isActive = true
        }
    }
    
    func constraint(_ attribute: NSLayoutAttribute, relatedBy: NSLayoutRelation = .equal, constant: CGFloat = 0.0, toItem: UIView? = nil, toAttribute: NSLayoutAttribute = .notAnAttribute) -> NSLayoutConstraint {
        let toAttributeChoice = toAttribute == .notAnAttribute ? attribute : toAttribute
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : toAttributeChoice, multiplier: 1.0, constant:constant)
        return constraint
    }
    
    var heightConstraint: NSLayoutConstraint { return constraintFor(.height) }
    var widthConstraint: NSLayoutConstraint { return constraintFor(.width) }
    var topConstraint: NSLayoutConstraint { return constraintFor(.top) }
    var bottomConstraint: NSLayoutConstraint { return constraintFor(.bottom) }
    var leadingConstraint: NSLayoutConstraint { return constraintFor(.leading) }
    var trailingConstraint: NSLayoutConstraint { return constraintFor(.trailing) }
    
    func constraintFor(_ attribute: NSLayoutAttribute, toItem: UIView? = nil) -> NSLayoutConstraint {
        guard let item = toItem as UIView! else {
            return constraints.filter({ return $0.firstAttribute == attribute }).first!
        }
        return constraints.filter({ return $0.firstAttribute == attribute && $0.firstItem as! UIView == item }).first!
    }
    
    func addSubviews(_ views: UIView...) { views.forEach { self.addSubview($0) } }
    
    func fadeIn(duration: TimeInterval = 0.2, completion:@escaping (() -> Void) = {}) {
        alpha = 0.0; UIView.animate(withDuration: duration, animations: { self.alpha = 1.0 }, completion: { _ in completion() })
    }
    
    func fadeOut(duration: TimeInterval = 0.2, completion:@escaping (() -> Void) = {}) {
        UIView.animate(withDuration: duration, animations: { self.alpha = 0.0 }, completion: { _ in completion() })
    }
}

extension UINavigationController {
    func push(_ viewController: UIViewController, animated: Bool = true) {
        pushViewController(viewController, animated: animated)
    }
    
    @discardableResult func pop(_ animated: Bool = true) {
        popViewController(animated: animated)
    }
}

extension UIViewController {
    func present(_ vc: UIViewController, animated: Bool = true) { present(vc, animated: animated, completion: nil) }
    func dismiss(animated: Bool = true) { dismiss(animated: animated, completion: nil) }
    func withNav() -> UINavigationController { return UINavigationController(rootViewController: self) }
}

extension UserDefaults {
    subscript(key: String) -> Any? { return object(forKey: key) }
}

extension Int {
    func perform(_ closure: () -> Void) { (0..<self).forEach { _ in closure() } }
    
    func performIndex(_ closure: @escaping (Int) -> Void) { (0..<self).forEach { index in closure(index) } }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    public subscript(safe index: Index) -> _Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

protocol Then {}
extension Then where Self: AnyObject {
    func then(_ block: (Self) -> Void) -> Self { block(self); return self }
}
extension NSObject: Then {}
