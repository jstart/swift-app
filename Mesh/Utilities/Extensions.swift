//
//  Extensions.swift
//  Mesh
//
//  Created by Christopher Truman on 8/23/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import SafariServices

let StandardDefaults = UserDefaults.standard
let DefaultNotification = NotificationCenter.default

let MainBundle = Bundle.main

extension String {
    private var qrImage: CIImage? {
        let textData = data(using: .isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(textData, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        return filter?.outputImage
    }
    
    func qrImage(withSize size: CGSize, foreground: UIColor = .black, background: UIColor = .white) -> UIImage? { return qrImage?.scaledWithSize(size).colored(withForeground: foreground, background: background)?.uiImage }
}

private extension CIImage {
    var uiImage: UIImage? { return UIImage(ciImage: self) }
    
    func scaledWithSize(_ size: CGSize) -> CIImage {
        let scaleX = size.width / extent.size.width, scaleY = size.height / extent.size.height
        return applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
    }
    
    func colored(withForeground foreground: UIColor, background: UIColor) -> CIImage? {
        return CIFilter(name: "CIFalseColor", withInputParameters: ["inputImage": self, "inputColor0": CIColor(uiColor: foreground), "inputColor1": CIColor(uiColor: background)])?.outputImage
    }
}

private extension CIColor {
    convenience init(uiColor: UIColor) {
        let foregroundColorRef = uiColor.cgColor, foregroundColorString = CIColor(cgColor: foregroundColorRef).stringRepresentation
        self.init(string: foregroundColorString)
    }
}

extension UIMotionEffectGroup { convenience init(_ motionEffects: [UIMotionEffect]) { self.init(); self.motionEffects = motionEffects } }

extension UIMotionEffect {
    class func twoAxesTilt(strength: Float) -> UIMotionEffect {
        func relativeValue(_ isMax: Bool, type: UIInterpolatingMotionEffectType) -> NSValue {
            var transform = CATransform3DIdentity
            transform.m34 = (1.0 * CGFloat(strength)) / 2000.0
            
            let axisValue: CGFloat
            if type == .tiltAlongVerticalAxis {
                axisValue = isMax ? -1.0 : 1.0
                transform = CATransform3DRotate(transform, axisValue * CGFloat(M_PI_4), 1, 0, 0)
            } else {
                axisValue = isMax ? 1.0 : -1.0
                transform = CATransform3DRotate(transform, axisValue * CGFloat(M_PI_4), 0, 1, 0)
            }
            return NSValue(caTransform3D: transform)
        }
        
        func motion(_ type: UIInterpolatingMotionEffectType) -> UIInterpolatingMotionEffect {
            let motion = UIInterpolatingMotionEffect(keyPath: "layer.transform", type: type)
            motion.minimumRelativeValue = relativeValue(false, type: type); motion.maximumRelativeValue = relativeValue(true, type: type)
            return motion
        }
        
        return UIMotionEffectGroup([motion(.tiltAlongHorizontalAxis), motion(.tiltAlongVerticalAxis)])
    }
}

extension UIImage {
    static func imageWithColor(_ color: UIColor, width: CGFloat = 1.0, height: CGFloat = 1.0) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor); context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext()
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
    static func sheet(title: String? = nil, message: String? = nil) -> UIAlertController { return UIAlertController(title: title, message: message, preferredStyle: .actionSheet) }
    static func alert(title: String? = nil, message: String? = nil) -> UIAlertController { return UIAlertController(title: title, message: message, preferredStyle: .alert) }
}

extension UIAlertAction {
    convenience init(_ title: String, style: UIAlertActionStyle = .default, handler: ((UIAlertAction) -> Swift.Void)? = nil) { self.init(title: title, style: style, handler: handler) }
    static func cancel(handler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertAction { return UIAlertAction("Cancel", style: .cancel, handler: handler) }
    static func ok(handler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertAction { return UIAlertAction("OK", style: .cancel, handler: handler) }
}

extension UIBarButtonItem {
    convenience init(_ image: UIImage, style: UIBarButtonItemStyle = .plain, target: AnyObject, action: Selector) { self.init(image: image, style: .plain, target: target, action: action) }
}

extension UIButton {
    var title : String { set { setTitle(newValue, for: .normal) } get { return title(for: .normal)! } }
    var titleColor : UIColor { set { setTitleColor(newValue, for: .normal) } get { return titleColor(for: .normal)! } }
    var image : UIImage { set { setImage(newValue, for: .normal) } get { return image(for: .normal)! } }
    override open var intrinsicContentSize : CGSize { get {
        let intrinsicContentSize = super.intrinsicContentSize
        let adjustedWidth = intrinsicContentSize.width + titleEdgeInsets.left + titleEdgeInsets.right
        let adjustedHeight = intrinsicContentSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom
        
        return CGSize(width: adjustedWidth, height: adjustedHeight) } }
}

extension UICollectionView {
    func registerClass(_ cellClasses: AnyClass...) { for aClass in cellClasses { register(aClass, forCellWithReuseIdentifier: String(describing: aClass)) } }
    func registerNib(_ cellClasses: AnyClass...) { for aClass in cellClasses { let string = String(describing: aClass); register(UINib(nibName: string, bundle: nil), forCellWithReuseIdentifier: string) } }
    func dequeue<T: UICollectionViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T { let string = String(describing: cellClass); return dequeueReusableCell(withReuseIdentifier: string, for: indexPath) as! T }
}

extension UITableView {
    func registerClass(_ cellClasses: AnyClass...) { for aClass in cellClasses { register(aClass, forCellReuseIdentifier: String(describing: aClass)) } }
    func registerNib(_ cellClasses: AnyClass...) { for aClass in cellClasses { let string = String(describing: aClass); register(UINib(nibName: string, bundle: nil), forCellReuseIdentifier: string) } }
    func dequeue<T: UITableViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T { let string = String(describing: cellClass); return dequeueReusableCell(withIdentifier: string, for: indexPath) as! T }
}

extension UIStackView {
    convenience init(_ views : UIView..., axis : UILayoutConstraintAxis = .horizontal, spacing : CGFloat = 0) { self.init(arrangedSubviews: views); self.axis = axis; self.spacing = spacing }
}

extension UIView {
    var translates: Bool { get { return translatesAutoresizingMaskIntoConstraints } set { translatesAutoresizingMaskIntoConstraints = newValue } }
    convenience init(translates: Bool) { self.init(); self.translates = translates }
    
    func constrain(_ constants : (attr: NSLayoutAttribute, const: CGFloat)..., toItem: UIView? = nil) {
        for constantPair in constants {
            NSLayoutConstraint(item: self, attribute: constantPair.attr, relatedBy: .equal, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : constantPair.attr, multiplier: 1.0, constant:constantPair.const).isActive = true
        }
    }
    
    func constrain(_ attributes: NSLayoutAttribute..., relatedBy: NSLayoutRelation = .equal, constant: CGFloat = 0.0, toItem: UIView? = nil, toAttribute: NSLayoutAttribute = .notAnAttribute, multiplier: CGFloat = 1.0) {
        for attribute in attributes {
            let toAttributeChoice = toAttribute == .notAnAttribute ? attribute : toAttribute
            NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : toAttributeChoice, multiplier: multiplier, constant:constant).isActive = true
        }
    }
    
    func constraint(_ attribute: NSLayoutAttribute, relatedBy: NSLayoutRelation = .equal, constant: CGFloat = 0.0, toItem: UIView? = nil, toAttribute: NSLayoutAttribute = .notAnAttribute, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        let toAttributeChoice = toAttribute == .notAnAttribute ? attribute : toAttribute
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : toAttributeChoice, multiplier: multiplier, constant:constant)
    }
    
    var heightConstraint: NSLayoutConstraint { return constraintFor(.height) }; var widthConstraint: NSLayoutConstraint { return constraintFor(.width) }
    var topConstraint: NSLayoutConstraint { return constraintFor(.top) }; var bottomConstraint: NSLayoutConstraint { return constraintFor(.bottom) }
    var leadingConstraint: NSLayoutConstraint { return constraintFor(.leading) }; var trailingConstraint: NSLayoutConstraint { return constraintFor(.trailing) }
    
    func constraintFor(_ attribute: NSLayoutAttribute, toItem: UIView? = nil) -> NSLayoutConstraint {
        guard let item = toItem as UIView! else { return constraints.filter({ return $0.firstAttribute == attribute }).first! }
        return constraints.filter({ return $0.firstAttribute == attribute && $0.firstItem as! UIView == item }).first!
    }
    
    func addSubviews(_ views: UIView...) { views.forEach { self.addSubview($0) } }
    
    func fadeIn(duration: TimeInterval = 0.2, delay: TimeInterval = 0, completion:@escaping (() -> Void) = {}) { alpha = 0.0; UIView.animate(withDuration: duration, delay: delay, animations: { self.alpha = 1.0 }, completion: { _ in completion() }) }
    func fadeOut(duration: TimeInterval = 0.2, delay: TimeInterval = 0, completion:@escaping (() -> Void) = {}) { UIView.animate(withDuration: duration, delay: delay, animations: { self.alpha = 0.0 }, completion: { _ in completion() }) }
    
    func scaleIn(delay: TimeInterval = 0, completion: @escaping ((Bool) -> Void) = {_ in }) {
        self.transform = self.transform.scaledBy(x: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 0.25, initialSpringVelocity: 5, options: .allowUserInteraction, animations: {
            self.transform = .identity }, completion: nil)
    }
    
    func squeezeIn(delay: TimeInterval = 0, completion: @escaping ((Bool) -> Void) = {_ in }) {
        UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 0.1, initialSpringVelocity: 1, options: .allowUserInteraction, animations: { self.transform = self.transform.scaledBy(x: 0.9, y: 0.9) }, completion: nil)
    }
    func squeezeOut(delay: TimeInterval = 0, completion: @escaping ((Bool) -> Void) = {_ in }) {
        UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .allowUserInteraction, animations: { self.transform = .identity }, completion: completion)
    }
    func squeezeInOut(delay: TimeInterval = 0, completion: @escaping ((Bool) -> Void) = {_ in }) { squeezeIn(delay: delay); squeezeOut(delay: 0.2, completion: completion) }
    
    func round(corners: UIRectCorner, radius: CGFloat = 10) {
        let rect = self.bounds
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer(); maskLayer.frame = rect; maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}

extension UINavigationController {
    func push(_ viewController: UIViewController, animated: Bool = true) { pushViewController(viewController, animated: animated) }
    @discardableResult func pop(_ animated: Bool = true) { popViewController(animated: animated) }
    
    func safari(_ url: String, push: Bool = true, delegate: SFSafariViewControllerDelegate? = nil) {
        let safari = SFSafariViewController(url: URL(string: url)!); safari.hidesBottomBarWhenPushed = true; safari.delegate = delegate
        if push { self.push(safari) }
        else { safari.modalPresentationStyle = .popover; self.present(safari) }
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
    init(_ bool: Bool) { self.init(bool ? 1 : 0) }
}

extension Collection {
    public subscript(safe index: Index) -> _Element? { return index >= startIndex && index < endIndex ? self[index] : nil }
}

protocol Then {}
extension Then where Self: AnyObject { func then(_ block: (Self) -> Void) -> Self { block(self); return self } }
extension NSObject: Then {}
