//
//  QuickPageControl.swift
//  Mesh
//
//  Created by Christopher Truman on 8/12/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

enum QuickViewCategory {
    case connections
    case experience
    case education
    case interests
    case events
    
    func imageName() -> String {
        return "settings"
        switch self {
        case .connections:
            return "connections.png"
        case .education:
            return "education.png"
        case .experience:
            return "experience.png"
        case .interests:
            return "interests.png"
        case .events:
            return "events.png"
        }
    }
    
    func button() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named:imageName()), for: .normal)
        return button
    }
}

struct QuickPageTab {
    var type : QuickViewCategory
}

class QuickPageControl {

    var stack : UIStackView? = nil
    
    init(categories: [QuickViewCategory]) {
        let array = categories.map({return $0.button()})
        stack = UIStackView(arrangedSubviews: array)
        stack?.spacing = 5
        stack?.distribution = .fillEqually
        stack?.alignment = .center
    }

}
