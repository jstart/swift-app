//
//  CardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import Alamofire

class CardViewController : UIViewController {
    var delegate : CardDelegate?
    
    var gestureRec : UIPanGestureRecognizer?
    var state = SwipeState()
    var control = QuickPageControl(categories: [.connections, .education, .experience, .interests, .events])
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = #colorLiteral(red: 0.631372549, green: 0.1568627451, blue: 0.2784313725, alpha: 1)
        
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        
        gestureRec = UIPanGestureRecognizer(target: self, action: #selector(pan))
        gestureRec?.isEnabled = false
        view.addGestureRecognizer(gestureRec!)
        
        view.addSubview(control.stack!)
        control.stack!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: control.stack!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant:40).isActive = true
        NSLayoutConstraint(item: control.stack!, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant:0).isActive = true
        NSLayoutConstraint(item: control.stack!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant:0).isActive = true
        NSLayoutConstraint(item: control.stack!, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant:0).isActive = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gestureRec?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gestureRec?.isEnabled = false
    }
    
    func pan(_ sender:UIPanGestureRecognizer){
        switch sender.state {
        case .ended:
            state.stop(gestureRec!)
            
            let swipeDirection = state.getSwipeDirection()
            if (!state.meetsDragRequirements(swipeDirection: swipeDirection)) {
                // Back to center
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.center = (self.view?.superview?.center)!
                })
                return
            }
            switch swipeDirection {
            case UISwipeGestureRecognizerDirection.up:
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.y = -400
                    }, completion: { _ in
                        self.removeSelf()
                })
                break
            case UISwipeGestureRecognizerDirection.left:
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.x = -400
                    }, completion: { _ in
                        self.removeSelf()
                })
                break
            case UISwipeGestureRecognizerDirection.right:
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.x = 400
                    }, completion: { _ in
                        self.removeSelf()
                })
                break
            case UISwipeGestureRecognizerDirection.down:
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.y = 800
                    }, completion: { _ in
                        self.removeSelf()
                })
                break
            default:
                // Back to center
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.center = (self.view?.superview?.center)!
                })
                break
            }
            
        case .began :
                state.start(gestureRec!)
                return;
        case .changed :
            state.drag(gestureRec!)
            let translation = sender.translation(in: view)
            sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
//            sender.view?.transform = CGAffineTransform(rotationAngle: CGFloat(180.0) / CGFloat(M_PI))

            sender.setTranslation(.zero, in: view)
        default: break
        }
    }
    
    func removeSelf(){
        view.removeFromSuperview()
        removeFromParentViewController()
        delegate?.swiped(.up)
    }
}
