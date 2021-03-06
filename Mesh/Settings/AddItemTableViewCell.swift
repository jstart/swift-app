//
//  AddItemTableViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class AddItemTableViewCell : UITableViewCell {
    
    let label = UILabel(translates: false).then { $0.textColor = Colors.brand }
    
    let icon = UIImageView(translates: false).then {
        $0.image = #imageLiteral(resourceName: "addCard").withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.brand
    }
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) { super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stack = UIStackView(icon, label, spacing: 5); stack.translates = false
        addSubviews(stack)
        stack.constrain(.centerX, .centerY, toItem: self)
    }
    
    func configure(_ itemType: String?) { label.text = "Add " + (itemType ?? "") }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
