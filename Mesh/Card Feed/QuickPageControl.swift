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
    case experience = "experience"
    case education = "education"
    case skills = "skills"
    case events = "events"
    
    func button() -> UIButton {
        return UIButton().then {
            $0.setImage(UIImage(named: rawValue), for: .normal)
            let activeImage = UIImage(named: rawValue)?.withRenderingMode(.alwaysTemplate)
            $0.setImage(activeImage, for: .selected)
            $0.tintColor = Colors.brand; $0.backgroundColor = .white
        }
    }
    
    func title() -> String { return rawValue.capitalized }

    func editFields() -> [EditField] {
        switch self {
        case .connections: return []
        case .experience: return Experience.fields
        case .education: return Education.fields
        case .skills: return []
        case .events: return [] }
    }
    
    static func index(_ category: String) -> Int {
        switch category {
        case "connections" : return 0
        case "experience" : return 1
        case "schools" : return 2
        case "interests" : return 3
        case "events" : return 4
        default: return 0 }
    }

}

protocol QuickPageControlDelegate: class { func selectedIndex(_ index: Int, animated: Bool) }

class QuickPageControl : NSObject, ViewPagerDelegate {

    var stack : UIStackView? = nil
    weak var delegate : QuickPageControlDelegate?
    var previousIndex = 0
    
    init(categories: [QuickViewCategory]) {
        let array = categories.map({return $0.button()})

        stack = UIStackView(arrangedSubviews: array).then {
            $0.translates = false
            $0.distribution = .fillEqually
            $0.alignment = .center
        }

        super.init()
        
        array.forEach({ $0.addTarget(self, action: #selector(selected), for: .touchUpInside) })
    }
    
    func selectIndex(_ index: Int) {
        for button in (stack?.subviews)! as! [UIButton] {
            if (stack?.subviews.index(of: button))! == index {
                previousIndex = index
                button.isSelected = true
            }else {
                button.isSelected = false
            }
        }
    }
    
    func selected(_ sender: UIButton) {
        for button in (stack?.subviews)! as! [UIButton] {
            button.isSelected = button == sender
        }
        delegate?.selectedIndex((stack?.subviews.index(of: sender))!, animated: true)
        previousIndex = (stack?.subviews.index(of: sender))!
    }
    
    func selectedIndex(_ index: Int) { selectIndex(index) }

}
