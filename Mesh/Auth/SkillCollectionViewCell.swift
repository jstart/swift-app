//
//  SkillCollectionViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SkillCollectionViewCell: UICollectionViewCell {
    
    let title = UILabel(translates: false).then {
        $0.font = .boldProxima(ofSize: 14)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = .gray
    }
    let popular = UILabel(translates: false).then {
        $0.isHidden = true
    }
    let icon = UIImageView(translates: false).then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white
    }
    let gradient = Colors.gradient
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.black.cgColor
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
        title.constrain((.height, 14))
        title.constrain((.centerX, 0), (.leading, 5), (.trailing, -5), toItem: self)
        title.constrain(.bottom, toItem: self, toAttribute: .bottomMargin)
        
//        addMotionEffect(UIMotionEffect.twoAxesTilt(strength: 0.5))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.title.text = ""
        self.icon.image = nil
        self.popular.isHidden = true
        gradient.removeFromSuperlayer()
    }
    
    func configure(_ title: String, image: UIImage, isPopular: Bool = false, searching: Bool = false) {
        self.title.text = title
        icon.image = image
        popular.isHidden = isPopular
        isSelected = isSelected ? true : false
        
        if searching { return }
//        let rotation = CABasicAnimation(keyPath: "transform.rotation.y")
//        rotation.duration = 0.75
//        rotation.fromValue = 0
//        rotation.toValue = 2 * CGFloat(M_PI)
//        layer.add(rotation, forKey: rotation.keyPath)
//
//        let crossFade = CABasicAnimation(keyPath:"transform.scale.x")
//        crossFade.duration = 0.75
//        crossFade.fromValue = 0.0
//        crossFade.toValue = 1
//        layer.add(crossFade, forKey: crossFade.keyPath)
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                icon.image = icon.image?.withRenderingMode(.alwaysTemplate)
                self.title.textColor = .white
                self.gradient.frame = self.contentView.frame
                self.contentView.layer.addSublayer(self.gradient)
            } else {
                icon.image = icon.image?.withRenderingMode(.alwaysOriginal)
                self.title.textColor = .gray
                gradient.removeFromSuperlayer()
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted && !self.isSelected {
                icon.image = icon.image?.withRenderingMode(.alwaysTemplate)
                self.title.textColor = .white
                gradient.frame = contentView.frame
                contentView.layer.addSublayer(gradient)
                let alpha = CABasicAnimation(keyPath: "opacity")
                alpha.fromValue = 0; alpha.toValue = 1
                alpha.duration = 0.2
                gradient.add(alpha, forKey: "opacity")
            } else {
                gradient.removeFromSuperlayer()
                icon.image = icon.image?.withRenderingMode(.alwaysOriginal)
                self.title.textColor = .gray
            }
        }
    }
    
}
