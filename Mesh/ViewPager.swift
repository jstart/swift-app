//
//  ViewPager.swift
//  Mesh
//
//  Created by Christopher Truman on 8/15/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

protocol ViewPagerDelegate {
    func selectedIndex(index: Int)
}

class ViewPager : NSObject, QuickPageControlDelegate, UIScrollViewDelegate {
    let scroll : UIScrollView = {
        let scroll = UIScrollView()
        scroll.isPagingEnabled = true
        scroll.alwaysBounceHorizontal = true
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    var delegate : ViewPagerDelegate?
    var views : [UIView] = []
    var previousPage = 0

    init(views : [UIView]) {
        let stack = UIStackView(arrangedSubviews: views)

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 30
        scroll.addSubview(stack)
        
        stack.constrain(.leading, constant: 15, toItem: scroll)
        stack.constrain(.trailing, constant: -15, toItem: scroll)
        stack.constrain(.centerY, .height, toItem: scroll)
        
        for view in stack.arrangedSubviews {
            view.constrain(.width, constant: -30, toItem: scroll)
        }
        
        super.init()
        scroll.delegate = self
    }
    
    func selectedIndex(_ index:Int){
        scroll.setContentOffset(CGPoint(x: scroll.frame.size.width * CGFloat(index), y: 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        let page = lround(Double(fractionalPage));
        if (previousPage != page) {
            delegate?.selectedIndex(index: page)
            previousPage = page;
        }
    }
}
