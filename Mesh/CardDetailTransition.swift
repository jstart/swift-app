//
//  CardDetailTransition.swift
//  Mesh
//
//  Created by Christopher Truman on 8/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class CardDetailTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    
//    override var duration: CGFloat = 0.2
    var presenting  = true
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)).then {
        $0.layer.cornerRadius = 5.0
        $0.translates = false
        $0.alpha = 0.0
    }
    var cardVC : CardViewController?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)-> TimeInterval {
        return TimeInterval(duration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        presenting ? present(transitionContext) : dismiss(transitionContext)
    }
    
    func present(_ context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        containerView.clipsToBounds = true
        containerView.frame.size.height = (cardVC?.view.frame.size.height)! + 81
        let detail = context.view(forKey: .to)!
        containerView.addSubview(detail)
        
        detail.translates = false
        detail.constrain(.width, .centerX, toItem: cardVC!.view)
        detail.constrain(.height, constant: -80, toItem: cardVC!.view)
        detail.constrain(.top, constant: 425, toItem: cardVC!.view)
        detail.alpha = 0.0
        
        detail.addSubview(blurView)
        blurView.constrain(.top, .width, .centerX, toItem: cardVC!.view)
        blurView.constrain(.height, toItem: cardVC!.imageView)
        
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(tap))
        containerView.addGestureRecognizer(tapRec)
        
        cardVC?.imageView.addSubview(blurView)
        
        UIView.animate(withDuration: 0.1, animations: {
            detail.alpha = 1.0
            self.blurView.alpha = 0.9
            }, completion:{_ in
                UIView.animate(withDuration: 0.2, animations: {
                    detail.frame.origin.y = 81 * 2
                    }, completion: { _ in
                        context.completeTransition(true)
                })
        })
    }
    
    func dismiss(_ context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        containerView.frame.size.height = (cardVC?.view.frame.size.height)! + 81
        let detail = context.view(forKey: UITransitionContextViewKey.from)!
        detail.frame.origin.y = 81 * 3
        containerView.addSubview(detail)
        
        UIView.animate(withDuration: 0.2, animations: {
            detail.frame.origin.y = 550
            detail.alpha = 0.0
            self.blurView.alpha = 0.0
            }, completion:{_ in
                context.completeTransition(true)
        })
    }
    

    func tap(_ sender:UITapGestureRecognizer) { cardVC?.dismiss() }
}
