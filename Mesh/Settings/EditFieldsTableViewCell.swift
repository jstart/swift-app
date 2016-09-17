//
//  EditFieldsTableViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EditFieldsTableViewCell : UITableViewCell {
    
    let first = SkyFloatingLabelTextField.branded("").then {
        $0.lineColor = .clear
        $0.selectedLineColor = .clear
    }
    let second = SkyFloatingLabelTextField.branded("").then {
        $0.lineColor = .clear
        $0.selectedLineColor = .clear
    }

    func configure(twoFields: Bool = false) {
        if twoFields {
            addSubviews(first, second)
            
            first.constrain((.height, -10), (.leading, 15), (.top, 5), toItem: self)
            second.constrain((.trailing, -15), (.height, -10), (.top, 5), toItem: self)
            second.constrain(.leading, constant: 5, toItem: first, toAttribute: .trailing)
            second.constrain((.width, 0), toItem: first)
        }else {
            addSubview(first)
            first.constrain((.height, -10), (.leading, 15), (.trailing, -15), (.top, 5), toItem: self)
        }
    }
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) { super.init(style: style, reuseIdentifier: reuseIdentifier) }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
