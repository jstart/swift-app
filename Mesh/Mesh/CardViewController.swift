//
//  CardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class CardViewController : UIViewController {
    var delegate : CardDelegate?
    
    var center : CGPoint = CGPoint(x: 0, y: 0)
    var gestureRec : UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.631372549, green: 0.1568627451, blue: 0.2784313725, alpha: 1)
        
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        
        gestureRec = UIPanGestureRecognizer(target: self, action: #selector(pan))
        gestureRec?.isEnabled = false
        view.addGestureRecognizer(gestureRec!)
        
        center = CGPoint(x: view.center.x, y: view.center.y - 60)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gestureRec?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gestureRec?.isEnabled = false
    }
    
    func pan(sender:UIPanGestureRecognizer){
        switch sender.state {
        case .ended:
            // Top
            if sender.view?.center.y < 30 {
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.y = -400
                    }, completion: { _ in
                      self.removeSelf()
                })
                return;
            }
            // Right
            if sender.view?.center.x > 200 {
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.x = 400
                    }, completion: { _ in
                        self.removeSelf()
                })
                return;
            }
            // Left
            if sender.view?.center.x < 150 {
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.x = -400
                    }, completion: { _ in
                        self.removeSelf()
                })
                return;
            }
            // Back to center
            UIView.animate(withDuration: 0.2, animations: {
                sender.view?.center = self.center
            })
            return;
        default: break
        }
        
        let translation = sender.translation(in: view)
        sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
        sender.setTranslation(.zero, in: view)
    }
    
    func removeSelf(){
        view.removeFromSuperview()
        removeFromParentViewController()
        delegate?.swiped(direction: .up)
    }
}
