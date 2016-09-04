//
//  ViewPager.swift
//  Mesh
//
//  Created by Christopher Truman on 8/15/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

protocol ViewPagerDelegate {
    func selectedIndex(_ index: Int)
}

class ViewPager : NSObject, QuickPageControlDelegate, UIScrollViewDelegate {
    let scroll = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.alwaysBounceHorizontal = true
        $0.showsHorizontalScrollIndicator = false
    }
    var delegate : ViewPagerDelegate?
    var views : [UIView] = []
    var previousPage = 0
    let stack : UIStackView

    init(views : [UIView]) {
        stack = UIStackView(arrangedSubviews: views)

        stack.translates = false
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 30
        scroll.addSubview(stack)
        
        stack.constrain(.leading, constant: 15, toItem: scroll)
        stack.constrain(.trailing, constant: -15, toItem: scroll)
        stack.constrain(.centerY, .height, toItem: scroll)
        
        for view in stack.arrangedSubviews {
            view.translates = false
            view.constrain(.width, constant: -30, toItem: scroll)
        }
        
        super.init()
        scroll.delegate = self
    }
    
    func insertView(_ view: UIView, atIndex: Int) {
        stack.insertArrangedSubview(view, at: atIndex)
        view.translates = false
        view.constrain(.width, constant: -30, toItem: scroll)
    }
    
    func currentView() -> UIView {
        return stack.arrangedSubviews[previousPage]
    }
    
    func removeView(atIndex: Int) {
        stack.arrangedSubviews[atIndex].removeFromSuperview()
    }
    
    func selectedIndex(_ index:Int, animated: Bool = true){
        guard index >= 0 else { return }
        scroll.setContentOffset(CGPoint(x: scroll.frame.size.width * CGFloat(index), y: scroll.contentOffset.y), animated: animated)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        let page = lround(Double(fractionalPage));
        if (previousPage != page && page >= 0) {
            delegate?.selectedIndex(page)
            previousPage = page;
        }
    }
}
