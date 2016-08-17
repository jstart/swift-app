//
//  QuickViewGenerator.swift
//  Mesh
//
//  Created by Christopher Truman on 8/15/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

struct QuickViewGenerator {
    
    static func viewsForDetails(userDetails: UserDetails) -> [UIView] {
        var views : [UIView] = []
        
        if userDetails.connections.count == 0 {
            views.append(tempQuickView())
        }
        if userDetails.experiences.count == 0 {
            views.append(tempQuickView())
        }
        if userDetails.educationItems.count == 0 {
            views.append(tempQuickView())
        }
        if userDetails.skills.count == 0 {
            views.append(tempQuickView())
        }
        if userDetails.events.count == 0 {
            views.append(tempQuickView())
        }
        return views
    }
    
    static func tempQuickView() -> UIStackView {
        var views : [UIView] = []
        for _ in 1...5 {
            views.append(square(image: #imageLiteral(resourceName: "settings"), title: "Test"))
        }
        let stack = stackOf(views: views)
        stack.constrain(.height, constant: 70)
        
        let label = UILabel()
        label.text = "Test"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.constrain(.height, constant: 20)
        
        let stackTitle = stackOf(views: [label, stack])
        stackTitle.distribution = .fillProportionally
        stackTitle.axis = .vertical
        stackTitle.alignment = .leading

        return stackTitle
    }
    
    static func stackOf(views: [UIView]) -> UIStackView {
        let view = UIStackView(arrangedSubviews: views)
        view.distribution = .fillEqually
        view.alignment = .center
        view.spacing = 5
        return view
    }
    
    static func square(image: UIImage, title: String) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.textAlignment = .center
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.constrain(.height, constant: 20)
        
        let icon = UIImageView(image: #imageLiteral(resourceName: "settings"))
        icon.layer.borderWidth = 1
        icon.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        icon.layer.cornerRadius = 5
        
        let view = UIStackView(arrangedSubviews: [icon, label])
        view.axis = .vertical
        view.spacing = 5
        
        return view
    }
}
