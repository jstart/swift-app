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
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var cardVC : CardViewController?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)-> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        if presenting {
            let detail = transitionContext.view(forKey: .to)!
            containerView.addSubview(detail)
            
            detail.translatesAutoresizingMaskIntoConstraints = false
            detail.constrain(.width, .centerX, toItem: cardVC!.view)
            detail.constrain(.height, constant: -80, toItem: cardVC!.view)
            detail.constrain(.top, constant: 400, toItem: cardVC!.view)
            detail.alpha = 0.0
            detail.layoutIfNeeded()

            blurView.layer.cornerRadius = 5.0
            detail.addSubview(blurView)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.constrain(.top, .width, .centerX, toItem: cardVC!.view)
            blurView.constrain(.height, toItem: cardVC!.imageView)
            blurView.alpha = 0.0
            let tapRec = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))

            containerView.addGestureRecognizer(tapRec)
            cardVC?.imageView.addSubview(blurView)
            
            containerView.bringSubview(toFront: detail)

            UIView.animate(withDuration: 0.1, animations: {
                    detail.alpha = 1.0
                    self.blurView.alpha = 0.9
                }, completion:{_ in
                    UIView.animate(withDuration: 0.1, animations: {
                        detail.frame.origin.y = 81 * 2
                        }, completion: {_ in
                            transitionContext.completeTransition(true)
                    })
            })
        } else {
            let detail = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            detail.frame.origin.y = 80 * 2
            containerView.addSubview(detail)
            containerView.bringSubview(toFront: detail)
            UIView.animate(withDuration: 0.1, animations: {
                detail.alpha = 0.0
                self.blurView.alpha = 0.0
                }, completion:{_ in
                    UIView.animate(withDuration: 0.1, animations: {
                        detail.frame.origin.y = 550
                        }, completion: {_ in
                            transitionContext.completeTransition(true)
                    })
            })
        }
    }

    func tap(sender:UITapGestureRecognizer) {
        cardVC!.dismiss(animated: true, completion: nil)
    }
}
