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
        
        let viewCount = Int(UIScreen.main.bounds.size.width / 70)
        
        for _ in 1...viewCount {
            views.append(square(#imageLiteral(resourceName: "tesla"), title: category.title()))
        }
        let stack = stackOf(views)
        stack.constrain(.height, constant: 75)
        
        let label = UILabel(translates: false).then {
            $0.backgroundColor = .white
            $0.text = category.title()
            $0.font = .proxima(ofSize: 14)
            $0.textAlignment = .center
            $0.textColor = .lightGray
            $0.constrain(.height, constant: 20)
        }
        
        return stackOf([label, stack]).then {
            $0.spacing = 5
            $0.axis = .vertical
            $0.alignment = .leading
        }
    }
    
    static func stackOf(_ views: [UIView]) -> UIStackView {
        return UIStackView(arrangedSubviews: views).then {
            $0.distribution = .fillProportionally
            $0.alignment = .center
            $0.spacing = 20
        }
    }
    
    static func square(_ image: UIImage, title: String) -> UIStackView {
        let label = UILabel(translates: false).then {
            $0.text = title
            $0.backgroundColor = .white
            $0.font = .proxima(ofSize: 12)
            $0.textAlignment = .center
            $0.textColor = .lightGray
            $0.constrain(.height, constant: 20)
        }
        let icon = UIImageView(image: image).then {
            $0.layer.borderWidth = 1
            $0.backgroundColor = .white
            $0.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            $0.layer.cornerRadius = 5
            $0.constrain(.width, .height, constant: 50)
        }
        
        return UIStackView(icon, label, axis: .vertical, spacing: 5)
    }
}
