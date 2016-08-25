//
//  QuickPageControl.swift
//  Mesh
//
//  Created by Christopher Truman on 8/12/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

enum QuickViewCategory : String  {
    case connections = "connections"
    case experience = "education"
    case education = "experience"
    case skills = "skills"
    case events = "events"
    
    func button() -> UIButton {
        return UIButton().then {
            $0.setImage(UIImage(named:rawValue), for: .normal)
            let activeImage = UIImage(named:rawValue + "Active")
            $0.setImage(activeImage, for: .selected)
            $0.backgroundColor = .white
        }
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
        stack?.spacing = 0
        stack?.distribution = .fillEqually
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
    
    func selectedIndex(_ index: Int){
        selectIndex(index)
    }

}
