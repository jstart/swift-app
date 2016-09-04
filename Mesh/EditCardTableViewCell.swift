//
//  EditCardTableViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EditCardTableViewCell : UITableViewCell {
    
    let icon = UIImageView().then {
        $0.translates = false
    }
    let contactField = UILabel().then {
        $0.translates = false
        $0.textColor = Colors.brand
    }
    let check = UIImageView().then {
        $0.translates = false
    }
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubviews(icon, contactField, check)
        
        icon.constrain(.leading, constant: 16, toItem: self)
        icon.constrain(.centerY, toItem: self)
        icon.constrain(.trailing, constant: -16, toItem: contactField, toAttribute: .leading)
        contactField.constrain(.centerY, toItem: self)
        check.constrain(.width, constant: 19)
        check.constrain(.trailing, constant: -16, toItem: self)
        check.constrain(.centerY, toItem: self)
    }
    
    func setChecked(_ selected: Bool) {
        check.image = selected ? #imageLiteral(resourceName: "checkMark") : nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
