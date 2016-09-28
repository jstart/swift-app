//
//  QuickReplyTransition.swift
//  Mesh
//
//  Created by Christopher Truman on 8/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class QuickReplyTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration    = 0.25
    var presenting  = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { return duration }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) { presenting ? present(transitionContext) : dismiss(transitionContext) }
    
    func present(_ context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView, detail = context.view(forKey: .to)!
        containerView.addSubview(detail)
        detail.translates = false
        detail.constrain(.centerX, .centerY, .width, .height, toItem: containerView)
        UIApplication.shared.delegate?.window??.windowLevel = UIWindowLevelStatusBar + 1

        containerView.fadeIn { context.completeTransition(true) }
    }
    
    func dismiss(_ context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        UIApplication.shared.delegate?.window??.windowLevel = UIWindowLevelNormal

        containerView.fadeOut { context.completeTransition(true) }
    }
    
}
