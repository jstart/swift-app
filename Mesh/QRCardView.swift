//
//  QRCardView.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class QRCardView: CardView {
    
    var stackView : UIStackView?
    
    let qrImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.constrain(.width, .height, constant: 100)
        $0.backgroundColor = AlertAction.defaultBackground
    }
    
    let name = UILabel().then {
        $0.textColor = .black
        $0.font = .boldSystemFont(ofSize: 22)
    }
    
    convenience init(_ user: UserResponse) {
        self.init()
        addSubview(qrImage)
        qrImage.constrain(.leading, constant: 15, toItem: self)
        qrImage.constrain(.centerY, toItem: self)
        
        name.text = user.fullName()
        let phone = detailLabel(user.phone_number ?? "")
        let title = detailLabel(user.title ?? "")

        stackView = UIStackView(arrangedSubviews: [name, title, phone]).then {
            $0.axis = .vertical
            $0.distribution = .equalSpacing
            $0.alignment = .leading
            $0.spacing = 2
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addSubview(stackView!)

        stackView?.constrain(.leading, constant: 10, toItem: qrImage, toAttribute: .trailing)
        stackView?.constrain(.trailing, constant: 10, toItem: self)

        stackView?.constrain(.centerY, toItem: self)
        stackView?.constrain(.top, relatedBy: .greaterThanOrEqual, constant: 10, toItem: self)
        stackView?.constrain(.bottom, relatedBy: .lessThanOrEqual, constant: -10, toItem: self)
    }
    
    func detailLabel(_ text: String) -> UILabel {
        return UILabel().then {
            $0.textColor = .lightGray
            $0.font = .systemFont(ofSize: 16)
            $0.text = text
        }
    }

}
