//
//  SkillCollectionViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

enum SkillAnimationDirection {
    case leftUp, up, rightUp, left, right, leftDown, down, rightDown
}

class SkillCollectionViewCell: UICollectionViewCell {
    
    let title = UILabel(translates: false).then { $0.font = .gothamBook(ofSize: 12); $0.textColor = .gray; $0.numberOfLines = 0; $0.textAlignment = .center }
    let popular = UILabel(translates: false).then { $0.isHidden = true }
    let icon = UIImageView(translates: false).then { $0.contentMode = .scaleAspectFit; $0.tintColor = .white; $0.constrain((.height, 50)) }
    let gradient = Colors.gradient
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        backgroundColor = .white
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true

        constrain(.width, toItem: self, toAttribute: .height)
        icon.constrain(.width, toItem: icon, toAttribute: .height)

        addSubviews(popular, icon, title)
        popular.constrain(.topMargin, .centerX, toItem: self)
        popular.constrain(.bottomMargin, toItem: icon)
        
        icon.constrain(.centerY, .centerX, toItem: self)
        
        title.constrain(.top, constant: 5, toItem: icon, toAttribute: .bottom)
        title.constrain((.height, 16))
        title.constrain((.centerX, 0), (.leading, 5), (.trailing, -5), toItem: self)
        title.constrain(.bottom, toItem: self, toAttribute: .bottomMargin)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.title.text = ""
        self.icon.image = nil
        self.icon.isHidden = false
        self.popular.isHidden = true
        gradient.removeFromSuperlayer()
        self.title.alpha = 1.0; self.icon.alpha = 1.0
        self.constraintFor(.bottom, toItem: self.title)?.isActive = true
        self.constraintFor(.centerY, toItem: title)?.isActive = false
        self.title.heightConstraint?.constant = 16

        self.layoutIfNeeded()
    }
    
    func configure(_ title: String?, image: UIImage?, isPopular: Bool = false, searching: Bool = false) {
        self.title.text = title
        icon.image = image
        popular.isHidden = isPopular
        isSelected = isSelected ? true : false
    }
    
    func configure(_ pickerItem: PickerResponse, isPopular: Bool = false, searching: Bool = false) {
        let attributedString = NSMutableAttributedString(string: pickerItem.name!)
        let paragraphStyle = NSMutableParagraphStyle(); paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: NSMakeRange(0, attributedString.length))
        self.title.attributedText = attributedString
        popular.isHidden = isPopular
        isSelected = isSelected ? true : false
        
        guard let url = pickerItem.logo else { return }
        guard let logoURL = URL(string: url) else { return }
        if url == "text" {
            icon.isHidden = true
            self.title.constrain(.centerY, toItem: self)
            self.title.numberOfLines = 0
            self.constraintFor(.bottom, toItem: self.title)?.isActive = false
            self.title.heightConstraint?.constant = 32
            return
        } else {
            self.constraintFor(.bottom, toItem: self.title)?.isActive = true
            self.icon.isHidden = false
            icon.af_setImage(withURL: logoURL, imageTransition: .crossDissolve(0.2))
        }
    }
    
    func animate(direction: SkillAnimationDirection = .left, row: Int = 0, distance: Int = 0, reverse: Bool = false, fadeOut: Bool = false) {
        var flipX : CGFloat = 0.0
        var flipY : CGFloat = 0.0
        switch direction {
        case .leftUp: flipY = -1.0; flipX = -1.0; break
        case .up: flipX = 1.0; break
        case .rightUp: flipY = 1.0; flipX = -1.0; break
        case .left: flipY = 1.0; break
        case .right: flipY = -1.0; break
        case .leftDown: flipY = -1.0; flipX = 1.0; break
        case .down: flipX = -1.0; break
        case .rightDown: flipY = 1.0; flipX = 1.0; break }
        UIView.animate(withDuration: 0.1, animations: { self.title.alpha = 0.0; self.icon.alpha = 0.0 })
        let rotation = CAKeyframeAnimation(keyPath: "transform")
        rotation.beginTime = CACurrentMediaTime() + (0.1 * Double(row + abs(distance)))
        rotation.duration = 0.5
        if reverse {
            var transform = CATransform3DRotate(layer.transform, CGFloat(M_PI), -flipX, -flipY, 0)
            transform.m34 = 1.0 / -150;
            rotation.values = [NSValue(caTransform3D: layer.transform),
                               NSValue(caTransform3D: transform),
                               NSValue(caTransform3D: CATransform3DRotate(layer.transform, CGFloat(M_PI), flipX, flipY, 0))]
        } else {
            var transform = CATransform3DRotate(layer.transform, CGFloat(M_PI), flipX, flipY, 0)
            transform.m34 = 1.0 / -150;
            rotation.values = [NSValue(caTransform3D: layer.transform),
                               NSValue(caTransform3D: transform),
                               NSValue(caTransform3D: CATransform3DRotate(layer.transform, CGFloat(M_PI), -flipX, -flipY, 0))]
        }
        layer.add(rotation, forKey: "r1")
        
        if fadeOut {
            UIView.animate(withDuration: 0.1, delay: 0.1 * Double(row + abs(distance)), animations: { self.alpha = 0.0 })
        }
        
        let scale = CABasicAnimation(keyPath:"transform.scale")
        scale.beginTime = CACurrentMediaTime() + (0.1 * Double(row + abs(distance)))
        scale.duration = 0.2
        scale.fromValue = 1.0; scale.toValue = 1.1
        scale.autoreverses = true
        layer.add(scale, forKey: scale.keyPath)

        //UIView.animate(withDuration: 0.1, delay: 0.65 + (0.1 * Double(row + abs(distance))), animations: { self.title.alpha = 1.0; self.icon.alpha = 1.0 })
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.title.textColor = .white
                self.gradient.frame = self.contentView.frame
                self.contentView.layer.addSublayer(self.gradient)
            } else {
                self.title.textColor = .gray
                gradient.removeFromSuperlayer()
            }
        }
    }
    
}
