//
//  EditCardTableViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EditCardTableViewCell : UITableViewCell {
    
    let icon = UIImageView(translates: false).then { $0.constrain(.width, constant: 19) }
    let contactField = UILabel(translates: false).then {
        $0.textColor = Colors.brand
        $0.font = .gothamBook(ofSize: 17)
    }
    let check = UIImageView(translates: false)
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubviews(icon, contactField, check)
        
        icon.constrain((.leading, 16), (.centerY, 0), toItem: self)
        icon.constrain(.trailing, constant: -16, toItem: contactField, toAttribute: .leading)
        
        contactField.constrain(.centerY, toItem: self)
        contactField.constrain(.trailing, constant: -5, toItem: check, toAttribute: .leading)
        
        check.constrain((.width, 19))
        check.constrain((.trailing, -16), (.centerY, 0), toItem: self)
    }
    
    func setChecked(_ selected: Bool) { check.image = selected ? #imageLiteral(resourceName: "checkMark") : nil }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
