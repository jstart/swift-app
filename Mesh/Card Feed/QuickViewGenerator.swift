//
//  QuickViewGenerator.swift
//  Mesh
//
//  Created by Christopher Truman on 8/15/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

struct QuickViewGenerator {
    
    static func viewsForDetails(_ userDetails: UserDetails?) -> [UIView] {
        var views : [UIView] = []
        
        if userDetails?.connections.count == 0 {
            views.append(tempQuickView(.connections))
        } else {
            views.append(quickView(Array(userDetails!.connections)))
        }
        if userDetails?.experiences.count == 0 {
            views.append(tempQuickView(.experience))
        } else if userDetails?.experiences.count == 1 {
            views.append(userDetailCell(userDetails!.experiences))
            //views.append(quickView(Array(userDetails!.experiences)))
        } else {
            views.append(quickView(Array(userDetails!.experiences)))
        }
        if userDetails?.educationItems.count == 0 {
            views.append(tempQuickView(.education))
        } else {
            views.append(userDetailCell(userDetails!.educationItems))
            //views.append(quickView(Array(userDetails!.educationItems)))
        }
        if userDetails?.skills.count == 0 {
            views.append(tempQuickView(.skills))
        } else {
            views.append(quickView(Array(userDetails!.skills)))
        }
        if userDetails?.events.count == 0 {
            views.append(tempQuickView(.events))
        } else {
            views.append(quickView(Array(userDetails!.events)))
        }
        
        return views
    }
    
    static func userDetailCell(_ details: [UserDetail]) -> UIView {
        
        let iconLabel = UILabel(translates: false).then {
            $0.text = details.first!.firstText
            $0.backgroundColor = .white; $0.textColor = .darkGray; $0.font = .gothamBook(ofSize: 15)
            $0.constrain(.height, constant: 20)
            $0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        }
        let subLabel = UILabel(translates: false).then {
            $0.text = details.first!.secondText
            $0.backgroundColor = .white; $0.textColor = .lightGray; $0.font = .gothamBook(ofSize: 13)
            $0.constrain(.height, constant: 20)
            $0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        }
        let icon = UIImageView(translates: false).then {
            $0.layer.borderWidth = 1
            $0.backgroundColor = .white
            $0.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            $0.layer.cornerRadius = 5
            $0.clipsToBounds = true
            $0.backgroundColor = .white
            $0.contentMode = .scaleAspectFit
            $0.constrain(.width, .height, constant: 50)
            $0.constrain(.width, toItem: $0, toAttribute: .height)
        }
        let container = UIView()
        
        container.addSubviews(iconLabel, subLabel, icon)
        
        icon.constrain((.top, 10), (.bottom, -10), toItem: container)
        icon.constrain(.leading, constant: 10, toItem: container)
        icon.constrain(.trailing, relatedBy: .lessThanOrEqual, constant: -10, toItem: container)
        icon.constrain(.centerY, toItem: container)
        
        iconLabel.constrain(.leading, constant: 13, toItem: icon, toAttribute: .trailing)
        iconLabel.constrain(.trailing, constant: -5, toItem: container, toAttribute: .trailing)
        iconLabel.constrain(.top, constant: 13, toItem: container)
        
        subLabel.constrain(.leading, .trailing, toItem: iconLabel)
        subLabel.constrain(.top, constant: 5, toItem: iconLabel, toAttribute: .bottom)
        
        if let url = details.first?.logo {
            DispatchQueue.global(qos: .userInitiated).async {
                icon.af_setImage(withURL: URL(string: url)!, imageTransition: .crossDissolve(0.2))
            }
        }
        
        let label = UILabel(translates: false).then {
            $0.backgroundColor = .white
            $0.text = details.first?.category.title().uppercased(); $0.font = .gothamBook(ofSize: 14); $0.textColor = .lightGray
            $0.textAlignment = .center
            $0.constrain(.height, constant: 16)
        }
        
        return stackOf([label, container]).then {
            $0.spacing = 0
            $0.axis = .vertical
            $0.alignment = .leading
            $0.distribution = .fill
        }
    }
    
    static func quickView(_ details: [UserDetail]) -> UIStackView {
        var views : [UIView] = []
        let count = min(3, details.count)
        for index in 0..<count {
            let detail = details[index]
            var contentMode = UIViewContentMode.scaleAspectFit
            if details.first?.category == .connections {
                contentMode = .scaleAspectFill
            }
            if count < 3 {
                let squareStack = fillSquare(.imageWithColor(.clear), title: detail.firstText, url: detail.logo, contentMode: contentMode)
                views.append(squareStack)
            } else {
                let squareStack = square(.imageWithColor(.clear), title: detail.firstText, url: detail.logo, contentMode: contentMode)
                views.append(squareStack)
            }
        }
        let stack = stackOf(views).then {
            $0.distribution = .fill
            //$0.constrain((.height, 50))
        }
        let label = UILabel(translates: false).then {
            $0.backgroundColor = .white
            $0.text = details.first?.category.title().uppercased(); $0.font = .gothamBook(ofSize: 14); $0.textColor = .lightGray
            $0.textAlignment = .center
            $0.constrain(.height, constant: 15)
        }
        
        return stackOf([label, stack]).then {
            $0.spacing = 5
            $0.axis = .vertical
            $0.alignment = .leading
            $0.distribution = .fill
        }
    }
    
    static func tempQuickView(_ category: QuickViewCategory) -> UIStackView {
        let holder = UIView().then { $0.constrain((.height, 75)) }
        let label = UILabel().then {
            $0.backgroundColor = .white
            $0.text = category.title().uppercased(); $0.font = .gothamBook(ofSize: 14); $0.textColor = .lightGray
            $0.textAlignment = .center
            $0.constrain(.height, constant: 20)
        }
        let fullStack = stackOf([label, holder]).then {
            $0.spacing = 5
            $0.axis = .vertical
            $0.alignment = .leading
            $0.distribution = .fill
        }
        
        holder.constrain(.width, toItem: fullStack)
        
        return fullStack
    }
    
    static func stackOf(_ views: [UIView]) -> UIStackView {
        return UIStackView(arrangedSubviews: views).then {
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 20
        }
    }
    
    static func fillSquare(_ image: UIImage?, title: String, url: String? = nil, contentMode: UIViewContentMode = .scaleAspectFit) -> UIView {
        let label = UILabel(translates: false).then {
            $0.text = title
            $0.backgroundColor = .white; $0.textColor = .lightGray; $0.font = .gothamBook(ofSize: 12)
            $0.textAlignment = .center
            $0.constrain(.height, constant: 20)
            $0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        }
        let icon = UIImageView(image: image).then {
            $0.translates = false
            $0.layer.borderWidth = 1
            $0.backgroundColor = .white
            $0.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            $0.layer.cornerRadius = 5
            $0.clipsToBounds = true
            $0.backgroundColor = .white
            $0.contentMode = contentMode
            $0.constrain(.width, .height, constant: 50)
            $0.constrain(.width, toItem: $0, toAttribute: .height)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = url { icon.af_setImage(withURL: URL(string: url)!, imageTransition: .crossDissolve(0.2)) }
        }
        
        return UIView(translates: false).then {
            $0.addSubviews(label, icon)
            $0.constrain((.height, 75))
            icon.constrain(.top, toItem: $0)
            icon.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: $0)
            icon.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: $0)
            icon.constrain(.centerX, toItem: label)

            label.constrain(.leading, .trailing, toItem: $0)
            label.constrain(.top, constant: 5, toItem: icon, toAttribute: .bottom)
        }
    }
    
    static func square(_ image: UIImage, title: String, url: String? = nil, contentMode: UIViewContentMode = .scaleAspectFit) -> UIView {
        let label = UILabel(translates: false).then {
            $0.text = title
            $0.backgroundColor = .white; $0.textColor = .lightGray; $0.font = .gothamBook(ofSize: 12)
            $0.textAlignment = .center
            $0.constrain(.height, constant: 20)
            $0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        }
        let icon = UIImageView(image: image).then {
            $0.translates = false
            $0.layer.borderWidth = 1
            $0.backgroundColor = .white
            $0.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            $0.layer.cornerRadius = 5
            $0.clipsToBounds = true
            $0.backgroundColor = .white
            $0.contentMode = contentMode
            $0.constrain(.width, .height, constant: 50)
            $0.constrain(.width, toItem: $0, toAttribute: .height)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = url { icon.af_setImage(withURL: URL(string: url)!, imageTransition: .crossDissolve(0.2)) }
        }
        
        return UIView(translates: false).then {
            $0.addSubviews(label, icon)
            $0.constrain((.height, 75))
            icon.constrain(.top, toItem: $0)
            icon.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: $0)
            icon.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: $0)
            icon.constrain(.centerX, toItem: label)
            
            label.constrain(.leading, .trailing, toItem: $0)
            label.constrain(.top, constant: 5, toItem: icon, toAttribute: .bottom)
        }
    }
    
    //TODO: MORE 6+
    static func moreCircle(_ count: Int) -> UILabel {
        return UILabel().then {
            $0.text = "+\(count)"
            $0.backgroundColor = .white; $0.textColor = .lightGray; $0.font = .gothamBook(ofSize: 12)
            $0.textAlignment = .center
            $0.constrain(.height, .width, constant: 20)
            $0.layer.cornerRadius = 10
            $0.layer.borderColor = UIColor.white.cgColor
            $0.layer.borderWidth = 1
        }
    }
}
