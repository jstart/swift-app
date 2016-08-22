//
//  QuickViewGenerator.swift
//  Mesh
//
//  Created by Christopher Truman on 8/15/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

struct QuickViewGenerator {
    
    static func viewsForDetails(userDetails: UserDetails?) -> [UIView] {
        var views : [UIView] = []
        
        if userDetails?.connections.count == 0 {
            views.append(tempQuickView(.connections))
        }
        if userDetails?.experiences.count == 0 {
            views.append(tempQuickView(.experience))
        }
        if userDetails?.educationItems.count == 0 {
            views.append(tempQuickView(.education))
        }
        if userDetails?.skills.count == 0 {
            views.append(tempQuickView(.skills))
        }
        if userDetails?.events.count == 0 {
            views.append(tempQuickView(.events))
        }
        return views
    }
    
    static func tempQuickView(_ category: QuickViewCategory) -> UIStackView {
        var views : [UIView] = []
        for _ in 1...5 {
            views.append(square(image: #imageLiteral(resourceName: "tesla"), title: "Test"))
        }
        let stack = stackOf(views: views)
        stack.constrain(.height, constant: 75)
        
        let label = UILabel()
        label.text = category.imageName().capitalized
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.constrain(.height, constant: 20)
        
        let stackTitle = stackOf(views: [label, stack])
        stackTitle.spacing = 5
        stackTitle.axis = .vertical
        stackTitle.alignment = .leading

        return stackTitle
    }
    
    static func stackOf(views: [UIView]) -> UIStackView {
        let view = UIStackView(arrangedSubviews: views)
        view.distribution = .fillProportionally
        view.alignment = .center
        view.spacing = 20
        return view
    }
    
    static func square(image: UIImage, title: String) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.constrain(.height, constant: 20)
        
        let icon = UIImageView(image: image)
        icon.layer.borderWidth = 1
        icon.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        icon.layer.cornerRadius = 5
        
        icon.constrain(.width, .height, constant: 50)
        
        let view = UIStackView(arrangedSubviews: [icon, label])
        view.axis = .vertical
        view.spacing = 5
        
        return view
    }
}
