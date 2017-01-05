//
//  CardDetailTransition.swift
//  Mesh
//
//  Created by Christopher Truman on 8/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class CardDetailTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
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
        let detail = context.view(forKey: .to)!
        containerView.addSubview(detail)
        
        detail.translates = false

        detail.constrain(.height, constant: 140)
        detail.constrain(.top, constant: containerView.frame.size.height - 140, toItem: containerView)
        detail.constrain((.width, -13), (.centerX, 0), toItem: containerView)
        detail.alpha = 0.0
        
        detail.addSubview(blurView)
        blurView.constrain(.top, toItem: cardVC!.view)
        blurView.constrain(.width, toItem: cardVC!.view)
        blurView.constrain(.centerX, toItem: cardVC!.view)
        blurView.constrain(.height, toItem: cardVC!.imageView)
        
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(tap))
        containerView.addGestureRecognizer(tapRec)
        
        cardVC?.imageView.addSubview(blurView)
        
        UIView.animate(withDuration: 0.1, animations: {
            detail.alpha = 1.0
            self.blurView.alpha = 0.9
        }, completion:{ _ in
            UIView.animate(withDuration: 0.2, animations: {
                containerView.constraintFor(.top, toItem: detail)?.constant = 81 * 2
                detail.heightConstraint?.constant = containerView.frame.size.height - 140
                containerView.layoutIfNeeded()
            }, completion: { _ in context.completeTransition(true) })
        })
    }
    
    func dismiss(_ context: UIViewControllerContextTransitioning) {
        UIView.setAnimationsEnabled(true)
        let containerView = context.containerView
        containerView.frame.size.height = (cardVC?.view.frame.size.height)! + 81
        let detail = context.view(forKey: UITransitionContextViewKey.from)!
        containerView.addSubview(detail)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.blurView.alpha = 0.0
            containerView.constraintFor(.top, toItem: detail)?.constant = containerView.frame.size.height - 140
            containerView.layoutIfNeeded()
            containerView.alpha = 0.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
            }, completion: { _ in
                context.completeTransition(true)
            })
        })
    }
    
    func tap(_ sender: UITapGestureRecognizer) { cardVC?.dismiss() }
}
