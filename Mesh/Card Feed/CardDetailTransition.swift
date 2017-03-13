//
//  CardDetailTransition.swift
//  Mesh
//
//  Created by Christopher Truman on 8/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class CardDetailTransition: NSObject, UIViewControllerAnimatedTransitioning { //UIViewControllerInteractiveTransitioning {
    
    let duration    = 1.0
    var presenting  = true
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)).then {
        $0.layer.cornerRadius = 10.0; $0.clipsToBounds = true; $0.translates = false; $0.alpha = 0.0
    }
    var cardVC : PersonCardViewController?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { return TimeInterval(duration) }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        presenting ? present(transitionContext) : dismiss(transitionContext)
    }
    
    func present(_ context: UIViewControllerContextTransitioning) {
        UIView.setAnimationsEnabled(true)
        let containerView = context.containerView
        containerView.clipsToBounds = true
        containerView.frame.size.height = (cardVC?.view.frame.size.height)! + 81
        let detailVC = context.viewController(forKey: .to) as! CardDetailViewController
        let detail = context.view(forKey: .to)!
        containerView.addSubview(detail)
        
        detail.translates = false
        
        detail.constrain(.height, constant: 140)
        detail.constrain(.top, constant: containerView.frame.size.height - 145, toItem: containerView)
        detail.constrain((.width, -13), (.centerX, 0), toItem: containerView)
        detail.alpha = 0.0
        
        detail.addSubview(blurView)
        blurView.constrain(.top, toItem: cardVC!.view)
        blurView.constrain(.width, toItem: cardVC!.view)
        blurView.constrain(.centerX, toItem: cardVC!.view)
        blurView.constrain(.height, constant: 10, toItem: cardVC!.imageView)
        
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(tap))
        containerView.addGestureRecognizer(tapRec)
        
        cardVC?.imageView.addSubview(blurView)
        
        UIView.animate(withDuration: 0.1, animations: {
            detail.alpha = 1.0
            self.blurView.alpha = 0.9
            self.cardVC?.name.alpha = 0.0
            self.cardVC?.position.alpha = 0.0
            self.cardVC?.logo.alpha = 0.0
            self.cardVC?.logoBackshadow.alpha = 0.0
            self.cardVC?.viewPager?.scroll.alpha = 0.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                containerView.constraintFor(.top, toItem: detail)?.constant = 81 * 2
                detail.heightConstraint?.constant = containerView.frame.size.height - 145
                containerView.layoutIfNeeded()
                detail.constraintFor(.width, toItem: detailVC.control.stack!)?.constant = -80
                detailVC.control.stack!.layoutIfNeeded()
            }, completion: { _ in context.completeTransition(true) })
        })
    }
    
    func dismiss(_ context: UIViewControllerContextTransitioning) {
        UIView.setAnimationsEnabled(true)
        let containerView = context.containerView
        containerView.frame.size.height = (cardVC?.view.frame.size.height)! + 81
        let detail = context.view(forKey: UITransitionContextViewKey.from)!
        let detailVC = context.viewController(forKey: .from) as! CardDetailViewController
        containerView.addSubview(detail)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.blurView.alpha = 0.0
            containerView.constraintFor(.top, toItem: detail)?.constant = containerView.frame.size.height - 145
            containerView.layoutIfNeeded()
            containerView.alpha = 0.0
            self.cardVC?.name.alpha = 1.0
            self.cardVC?.position.alpha = 1.0
            self.cardVC?.logo.alpha = 1.0
            self.cardVC?.logoBackshadow.alpha = 1.0
            self.cardVC?.viewPager?.scroll.alpha = 1.0
            detail.constraintFor(.width, toItem: detailVC.control.stack!)?.constant = -160
            detailVC.control.stack!.layoutIfNeeded()
        }, completion: { _ in context.completeTransition(true) })
    }
    
//    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
//        presenting ? present(transitionContext) : dismiss(transitionContext)
//    }
    
    func tap(_ sender: UITapGestureRecognizer) { cardVC?.dismiss() }
    
}
