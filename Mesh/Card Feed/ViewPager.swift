//
//  ViewPager.swift
//  Mesh
//
//  Created by Christopher Truman on 8/15/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

protocol ViewPagerDelegate : class {
    func selectedIndex(_ index: Int)
}

enum ViewPagerAnimation {
    case none, tilt
}

class ViewPager : NSObject, QuickPageControlDelegate, UIScrollViewDelegate {
    let scroll = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.alwaysBounceHorizontal = true
        $0.showsHorizontalScrollIndicator = false
    }
    weak var delegate : ViewPagerDelegate?
    var views : [UIView] = []
    var previousPage = 0
    let stack : UIStackView
    let animation : ViewPagerAnimation

    init(views : [UIView], animation: ViewPagerAnimation = .none) {
        self.animation = animation
        stack = UIStackView(arrangedSubviews: views).then {
            $0.translates = false
            $0.distribution = .fill; $0.alignment = .center
            $0.spacing = 30
        }
        
        scroll.addSubview(stack)
        
        stack.constrain((.leading, 15), (.trailing, -15), toItem: scroll)
        stack.constrain(.centerY, .height, toItem: scroll)
        
        for view in stack.arrangedSubviews {
            view.translates = false
            let width = view.constraint(.width, constant: -30, toItem: scroll)
            width.priority = UILayoutPriorityDefaultHigh
            width.isActive = true
        }
        
        super.init()
        scroll.delegate = self
    }
    
    func insertViews(_ views: [UIView]) { for (index, view) in views.enumerated() { insertView(view, atIndex: index) } }
    
    func insertView(_ view: UIView, atIndex: Int) {
        stack.insertArrangedSubview(view, at: atIndex)
        view.translates = false
        let width = view.constraint(.width, constant: -30, toItem: scroll)
        width.priority = UILayoutPriorityDefaultHigh
        width.isActive = true
    }
    
    func currentView() -> UIView { return stack.arrangedSubviews[previousPage] }
    
    func removeView(atIndex: Int) { stack.arrangedSubviews[atIndex].removeFromSuperview() }
    func removeAllViews() { stack.arrangedSubviews.forEach { $0.removeFromSuperview() } }

    func selectedIndex(_ index: Int, animated: Bool = true) {
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
        
        /*let progress = (scrollView.contentOffset.x/scrollView.contentSize.width) * 3
        for (index, view) in stack.arrangedSubviews.enumerated() {
            if index != page {
                view.transform = CGAffineTransform(rotationAngle: (-fractionalPage * CGFloat(-M_PI_2))/2)
            }
        }*/
    }
}
