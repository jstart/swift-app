//
//  ViewPager.swift
//  Mesh
//
//  Created by Christopher Truman on 8/15/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

struct ViewPager : QuickPageControlDelegate {
    let scroll : UIScrollView = {
        let scroll = UIScrollView()
        //scroll.isPagingEnabled = true
        return scroll
    }()
    var views : [UIView] = []
    
    init(views : [UIView]) {
        let stack = UIStackView(arrangedSubviews: views)

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.alignment = .center
        scroll.addSubview(stack)
        stack.constrain(.leading, toItem: scroll)
        stack.constrain(.centerY, toItem: scroll)
        stack.constrain(.height, toItem: scroll)
        
        for view in stack.arrangedSubviews {
            view.constrain(.width, toItem: scroll)
        }
    }
    
    func selectedIndex(_ index:Int){
        scroll.setContentOffset(CGPoint(x: scroll.frame.size.width * CGFloat(index), y: 0), animated: true)
    }
}
