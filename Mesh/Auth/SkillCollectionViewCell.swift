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
        $0.backgroundColor = .white
    }
    let popular = UILabel(translates: false).then {
        $0.isHidden = true
        $0.backgroundColor = .white
    }
    let icon = UIImageView(translates: false).then {
        $0.backgroundColor = .white
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.black.cgColor
        backgroundColor = .white
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor = .white
        
        constrain(.width, toItem: self, toAttribute: .height)
        
        addSubviews(popular, icon, title)
        popular.constrain(.topMargin, .centerX, toItem: self)
        popular.constrain(.bottomMargin, toItem: icon)
        
        icon.constrain(.centerY, .centerX, toItem: self)
        
        title.constrain(.top, constant: 5, toItem: icon, toAttribute: .bottom)
        title.constrain(.centerX, toItem: self)
        title.constrain(.bottom, toItem: self, toAttribute: .bottomMargin)
        
        addMotionEffect(UIMotionEffect.twoAxesTilt(strength: 0.5))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.title.text = ""
        self.icon.image = nil
        self.popular.isHidden = true
    }
    
    func configure(_ title: String, image: UIImage, isPopular: Bool = false) {
        self.title.text = title
        self.icon.image = image
        self.popular.isHidden = isPopular
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotation.duration = 0.75
        rotation.fromValue = 0
        rotation.toValue = 2 * CGFloat(M_PI)
        layer.add(rotation, forKey: rotation.keyPath)

        let crossFade = CABasicAnimation(keyPath:"transform.scale.x")
        crossFade.duration = 0.75
        crossFade.fromValue = 0.0
        crossFade.toValue = 1
        layer.add(crossFade, forKey: crossFade.keyPath)
    }
    
    override var isSelected: Bool {
        didSet {
            icon.backgroundColor = self.isSelected ? .clear : .white
            popular.backgroundColor = self.isSelected ? .clear : .white
            title.backgroundColor = self.isSelected ? .clear : .white
            contentView.backgroundColor = self.isSelected ? UIColor.black.withAlphaComponent(0.25) : .white
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            icon.backgroundColor = self.isHighlighted ? .clear : .white
            popular.backgroundColor = self.isHighlighted ? .clear : .white
            title.backgroundColor = self.isHighlighted ? .clear : .white
            contentView.backgroundColor = self.isHighlighted ? UIColor.black.withAlphaComponent(0.25) : .white
        }
    }
    
}
