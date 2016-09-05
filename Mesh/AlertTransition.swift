//
//  AlertTransition.swift
//  Mesh
//
//  Created by Christopher Truman on 8/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class AlertTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration    = 0.25
    var presenting  = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)-> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        presenting ? present(transitionContext) : dismiss(transitionContext)
    }
    
    func present(_ context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        let detail = context.view(forKey: .to)!
        containerView.addSubview(detail)
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        detail.translates = false
        detail.alpha = 0.0
        detail.constrain(.centerX, .centerY, toItem: containerView)
        
        UIView.animate(withDuration: duration, animations: {
            detail.alpha = 1.0
            }, completion:{_ in context.completeTransition(true) })
    }
    
    func dismiss(_ context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        let detail = context.view(forKey: UITransitionContextViewKey.from)!
        containerView.addSubview(detail)
        
        UIView.animate(withDuration: duration, animations: {
            detail.alpha = 0.0
            }, completion:{_ in context.completeTransition(true) })
    }
}
