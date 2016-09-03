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
    func selectedIndex(_ index:Int, animated:Bool)
}

class QuickPageControl : NSObject, ViewPagerDelegate {

    var stack : UIStackView? = nil
    var delegate : QuickPageControlDelegate?
    var previousIndex = 0
    
    init(categories: [QuickViewCategory]) {
        let array = categories.map({return $0.button()})
        
        stack = UIStackView(arrangedSubviews: array).then {
            $0.spacing = 0
            $0.distribution = .fillEqually
            $0.alignment = .center
        }

        super.init()
        
        array.forEach({ button in
            button.addTarget(self, action: #selector(selected), for: .touchUpInside)
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
    
    func selected(_ sender : UIButton){
        for button in (stack?.subviews)! as! [UIButton] {
            button.isSelected = button == sender
        }
        delegate?.selectedIndex((stack?.subviews.index(of: sender))!, animated: true)
        previousIndex = (stack?.subviews.index(of: sender))!
    }
    
    func selectedIndex(_ index: Int){
        selectIndex(index)
    }

}
