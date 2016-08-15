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
        let tintImage = UIImage(named:imageName())?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintImage, for: .highlighted)
        button.setImage(tintImage, for: .selected)

        return button
    }
}

protocol QuickPageControlDelegate {
    func selectedIndex(_ index:Int)
    
}

class QuickPageControl : NSObject {

    var stack : UIStackView? = nil
    var delegate : QuickPageControlDelegate?
    
    init(categories: [QuickViewCategory]) {
        let array = categories.map({return $0.button()})
        
        stack = UIStackView(arrangedSubviews: array)
        stack?.spacing = 5
        stack?.distribution = .fillEqually
        stack?.alignment = .center
        
        super.init()
        
        array.forEach({ button in
            button.addTarget(self, action: #selector(selected(sender:)), for: .touchUpInside)
        })
    }
    
    func selectIndex(_ index:Int){
        for button in (stack?.subviews)! as! [UIButton] {
            button.isSelected = true
        }
    }
    
    func selected(sender : UIButton){
        for button in (stack?.subviews)! as! [UIButton] {
            button.isSelected = button == sender
        }
        delegate?.selectedIndex((stack?.subviews.index(of: sender))!)
    }

}
