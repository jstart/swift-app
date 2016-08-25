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
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)).then {
        $0.layer.cornerRadius = 5.0
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alpha = 0.0
    }
    var cardVC : CardViewController?
    
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
        
        detail.translatesAutoresizingMaskIntoConstraints = false
        detail.constrain(.width, .centerX, toItem: cardVC!.view)
        detail.constrain(.height, constant: -80, toItem: cardVC!.view)
        detail.constrain(.top, constant: 400, toItem: cardVC!.view)
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
                UIView.animate(withDuration: 0.1, animations: {
                    detail.frame.origin.y = 81 * 2
                    }, completion: {_ in
                        context.completeTransition(true)
                })
        })
    }
    
    func dismiss(_ context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        let detail = context.view(forKey: UITransitionContextViewKey.from)!
        detail.frame.origin.y = 80 * 2
        containerView.addSubview(detail)
        
        UIView.animate(withDuration: 0.1, animations: {
            detail.alpha = 0.0
            self.blurView.alpha = 0.0
            }, completion:{_ in
                UIView.animate(withDuration: 0.1, animations: {
                    detail.frame.origin.y = 550
                    }, completion: {_ in
                        context.completeTransition(true)
                })
        })
    }

    func tap(_ sender:UITapGestureRecognizer) {
        cardVC!.dismiss(animated: true, completion: nil)
    }
}
