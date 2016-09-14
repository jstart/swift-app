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
        $0.font = .boldProxima(ofSize: 20)
    }
    let popular = UILabel(translates: false).then {
        $0.isHidden = true
    }
    let icon = UIImageView(translates: false)
    
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews(popular, icon, title)
        
        icon.constrain(.centerX, .centerY, toItem: self)
        
        title.constrain(.centerX, toItem: self)
        title.constrain(.top, toItem: self, toAttribute: .bottomMargin)
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
    }
    
}
