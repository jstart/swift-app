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
        }
        if userDetails?.experiences.count == 0 {
            views.append(tempQuickView(.experience))
        } else if userDetails?.experiences.count == 1 {
            views.append(userDetailCell(userDetails!.experiences))
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
        }
        return views
    }
    
    static func userDetailCell(_ details: [UserDetail]) -> UIView {
        let cell = (MainBundle.loadNibNamed("UserDetailTableViewCell", owner: nil, options: [:])!.first as! UserDetailTableViewCell).then {
            $0.contentView.translates = false
            $0.configure(details.first!)
        }
        let label = UILabel(translates: false).then {
            $0.backgroundColor = .white
            $0.text = details.first?.category.title(); $0.font = .gothamBook(ofSize: 14); $0.textColor = .lightGray
            $0.textAlignment = .center
            $0.constrain(.height, constant: 20)
        }
        
        return stackOf([label, cell.contentView]).then {
            $0.spacing = 1
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
            if count < 3 {
                let squareStack = fillSquare(.imageWithColor(.darkGray), title: detail.firstText, url: detail.logo)
                views.append(squareStack)
            } else {
                let squareStack = square(.imageWithColor(.darkGray), title: detail.firstText, url: detail.logo)
                views.append(squareStack)
            }
        }
        let stack = stackOf(views).then {
            $0.distribution = .fillEqually
        }
        let label = UILabel(translates: false).then {
            $0.backgroundColor = .white
            $0.text = details.first?.category.title(); $0.font = .gothamBook(ofSize: 14); $0.textColor = .lightGray
            $0.textAlignment = .center
            $0.constrain(.height, constant: 20)
        }
        
        return stackOf([label, stack]).then {
            $0.spacing = 5
            $0.axis = .vertical
            $0.alignment = .leading
            $0.distribution = .fill
        }
    }
    
    static func tempQuickView(_ category: QuickViewCategory) -> UIStackView {
        var views : [UIView] = []
        
        views.append(fillSquare(nil, title: ""))
        let stack = stackOf(views).then { $0.distribution = .fillEqually }
        let label = UILabel().then {
            $0.backgroundColor = .white
            $0.text = category.title(); $0.font = .gothamBook(ofSize: 14); $0.textColor = .lightGray
            $0.textAlignment = .center
            $0.constrain(.height, constant: 20)
        }
        let fullStack = stackOf([label, stack]).then {
            $0.spacing = 5
            $0.axis = .vertical
            $0.alignment = .leading
            $0.distribution = .fill
        }
        
        stack.constrain(.width, relatedBy: .lessThanOrEqual, toItem: fullStack)
        
        return fullStack
    }
    
    static func stackOf(_ views: [UIView]) -> UIStackView {
        return UIStackView(arrangedSubviews: views).then {
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 20
        }
    }
    
    static func fillSquare(_ image: UIImage?, title: String, url: String? = nil) -> UIStackView {
        let label = UILabel().then {
            $0.numberOfLines = 2
            $0.text = title; $0.font = .gothamBook(ofSize: 12); $0.textColor = .lightGray
            $0.backgroundColor = .white
            $0.textAlignment = .center
            $0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            $0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        }
        let icon = UIImageView(image: image).then {
            $0.translates = false
            $0.layer.borderWidth = 1
            $0.backgroundColor = .white
            $0.layer.borderColor = image != nil ? UIColor.lightGray.withAlphaComponent(0.5).cgColor : UIColor.clear.cgColor
            $0.layer.cornerRadius = 5
            $0.clipsToBounds = true
            $0.backgroundColor = .white
            $0.contentMode = .scaleAspectFit
            $0.constrain(.height, .width, constant: 50)
        }
        
        let container = UIView()
        container.addSubview(icon)
        icon.constrain(.centerX, .centerY, .top, .bottom, toItem: container)
        icon.constrain(.leading, relatedBy: .greaterThanOrEqual, toItem: container)
        icon.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: container)

        if let url = url { icon.af_setImage(withURL: URL(string: url)!, imageTransition: .crossDissolve(0.2)) }
        
        return UIStackView(container, label, axis: .vertical, spacing: 5)
    }
    
    static func square(_ image: UIImage, title: String, url: String? = nil) -> UIStackView {
        let label = UILabel().then {
            $0.text = title
            $0.backgroundColor = .white; $0.textColor = .lightGray; $0.font = .gothamBook(ofSize: 12)
            $0.textAlignment = .center
            $0.constrain(.height, constant: 20)
            $0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        }
        let icon = UIImageView(image: image).then {
            $0.layer.borderWidth = 1
            $0.backgroundColor = .white
            $0.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            $0.layer.cornerRadius = 5
            $0.clipsToBounds = true
            $0.backgroundColor = .white
            $0.contentMode = .scaleAspectFit
            $0.constrain(.width, .height, constant: 50)
        }
        
        if let url = url { icon.af_setImage(withURL: URL(string: url)!, imageTransition: .crossDissolve(0.2)) }
        
        return UIStackView(icon, label, axis: .vertical, spacing: 5)
    }
    
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
