//
//  CardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class CardViewController : UIViewController {
    
    var center : CGPoint = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.631372549, green: 0.1568627451, blue: 0.2784313725, alpha: 1)
        
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        
        let gestureRec = UIPanGestureRecognizer(target: self, action: #selector(pan))
        view.addGestureRecognizer(gestureRec)
        
        center = CGPoint(x: view.center.x, y: view.center.y - 60)
    }
    
    func pan(sender:UIPanGestureRecognizer){
        switch sender.state {
        case .ended:
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
}
