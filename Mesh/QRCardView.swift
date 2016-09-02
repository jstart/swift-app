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
    
    let title = QRCardView.detailLabel("")
    let email = QRCardView.detailLabel("")
    let phone = QRCardView.detailLabel("")

    convenience init(_ user: UserResponse, fields: [ProfileFields]) {
        self.init()
        addSubview(qrImage)
        qrImage.constrain(.leading, constant: 15, toItem: self)
        qrImage.constrain(.centerY, toItem: self)
        
        name.text = user.fullName()
        title.text = user.fullTitle()
        email.text = "email@test.com"
        phone.text = user.phone_number ?? ""
        
        viewsForFields(fields).forEach({ $0.isHidden = false })

        stackView = UIStackView(arrangedSubviews: [name, title, email, phone]).then {
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
    
    func updateFields(_ fields: [ProfileFields]) {
        stackView?.arrangedSubviews.forEach({ $0.isHidden = true })
        viewsForFields(fields).forEach({ $0.isHidden = false })
    }
    
    func viewsForFields(_ fields: [ProfileFields]) -> [UIView] {
        var views = [UIView]()
        for field in fields {
            switch field {
            case .name:
                views.append(name)
                break
            case .title:
                views.append(title)
                break
            case .email:
                views.append(email)
                break
            case .phone:
                views.append(phone)
                break
            }
        }
        return views
    }
    
    static func detailLabel(_ text: String) -> UILabel {
        return UILabel().then {
            $0.textColor = .lightGray
            $0.font = .systemFont(ofSize: 16)
            $0.text = text
            $0.isHidden = true
        }
    }

}
