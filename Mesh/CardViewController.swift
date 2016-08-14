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
        
        let stack = UIStackView(arrangedSubviews: [bar(), control.stack!, bar()])
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 10

        view.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.constrain(.height, constant: 30)
        stack.constrain(.width, constant: 0, toItem: view)
        stack.constrain(.centerX, constant: 0, toItem: view)
        stack.constrain(.centerY, constant: 0, toItem: view)
        
        control.stack!.constrain(.width, constant: 100)
    }
    
    func bar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = UIColor.gray
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.constrain(.height, constant: 1)
        bar.constrain(.width, constant: 40)
        return bar
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
