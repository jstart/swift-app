//
//  CardDetailTransition.swift
//  Mesh
//
//  Created by Christopher Truman on 8/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class CardDetailTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration    = 0.2
    var presenting  = true
    var cardVC : CardViewController?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)-> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        if presenting {
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            let detail = toView
            containerView.addSubview(toView)
            
            detail.translatesAutoresizingMaskIntoConstraints = false
            detail.constrain(.width, toItem: cardVC!.view)
            detail.constrain(.height, constant: -80, toItem: cardVC!.view)
            detail.constrain(.centerX, toItem: cardVC!.view)
            detail.constrain(.centerY, constant: 40, toItem: cardVC!.view)
            detail.alpha = 0.0

            let blurView = UIView()
            blurView.backgroundColor = .black
            blurView.alpha = 0.7
            blurView.layer.cornerRadius = 5.0
            
            detail.addSubview(blurView)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.constrain(.top, .width, .centerX, toItem: cardVC!.view)
            blurView.constrain(.height, constant: 80)
            
            containerView.bringSubview(toFront: detail)

            UIView.animate(withDuration: duration, animations: {
                    detail.alpha = 1.0
                }, completion:{_ in
                    transitionContext.completeTransition(true)
            })
        } else {
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            let detail = toView
            
            containerView.addSubview(toView)
            containerView.bringSubview(toFront: detail)
            
            UIView.animate(withDuration: duration, animations: {
                            detail.alpha = 0.0
                }, completion:{_ in
                    transitionContext.completeTransition(true)
            })
        }
        
    }
    
}
