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
    case skills
    case events
    
    func imageName() -> String {
        switch self {
        case .connections:
            return "connections"
        case .education:
            return "education"
        case .experience:
            return "experience"
        case .skills:
            return "skills"
        case .events:
            return "events"
        }
    }
    
    func button() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named:imageName()), for: .normal)
        let activeImage = UIImage(named:imageName() + "Active")
        button.setImage(activeImage, for: .highlighted)
        button.setImage(activeImage, for: .selected)
        return button
    }
}

protocol QuickPageControlDelegate {
    func selectedIndex(_ index:Int)
}

class QuickPageControl : NSObject, ViewPagerDelegate {

    var stack : UIStackView? = nil
    var delegate : QuickPageControlDelegate?
    var previousIndex = 0
    
    init(categories: [QuickViewCategory]) {
        let array = categories.map({return $0.button()})
        
        stack = UIStackView(arrangedSubviews: array)
        stack?.spacing = 20
        stack?.distribution = .equalSpacing
        stack?.alignment = .center

        super.init()
        
        array.forEach({ button in
            button.addTarget(self, action: #selector(selected(sender:)), for: .touchUpInside)
        })
    }
    
    func selectIndex(_ index:Int){
        for button in (stack?.subviews)! as! [UIButton] {
            if (stack?.subviews.index(of: button))! == index {
                previousIndex = index
                button.isSelected = true
            }else {
                button.isSelected = false
            }
        }
    }
    
    func selected(sender : UIButton){
        for button in (stack?.subviews)! as! [UIButton] {
            button.isSelected = button == sender
        }
        delegate?.selectedIndex((stack?.subviews.index(of: sender))!)
        previousIndex = (stack?.subviews.index(of: sender))!
    }
    
    func selectedIndex(index: Int){
        selectIndex(index)
    }

}
