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
    
    lazy var image : UIImageView =  {
        let image = UIImageView(image: #imageLiteral(resourceName: "profile_sample"))
        return image
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = #colorLiteral(red: 0.631372549, green: 0.1568627451, blue: 0.2784313725, alpha: 1)
        
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        
        gestureRec = UIPanGestureRecognizer(target: self, action: #selector(pan))
        gestureRec?.isEnabled = false
        view.addGestureRecognizer(gestureRec!)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let quickViewStack = UIStackView(arrangedSubviews: [bar(), control.stack!, bar()])
        quickViewStack.distribution = .fillProportionally
        quickViewStack.alignment = .center
        quickViewStack.spacing = 10
        
        let viewExpand = UIView()
        viewExpand.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: viewExpand, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0).isActive = true
        
        let topStack = UIStackView(arrangedSubviews: [image, quickViewStack, viewExpand])
        topStack.axis = .vertical
        topStack.distribution = .fillProportionally
        topStack.alignment = .center
        topStack.spacing = 10
        
        view.addSubview(topStack)
        
        topStack.translatesAutoresizingMaskIntoConstraints = false
        topStack.constrain(.top, toItem: view)
        topStack.constrain(.height, constant: 0, toItem: view)
        topStack.constrain(.width, constant: 0, toItem: view)
        
        quickViewStack.translatesAutoresizingMaskIntoConstraints = false
        quickViewStack.constrain(.height, constant: 30)
        quickViewStack.constrain(.width, constant: 0, toItem: view)
        quickViewStack.constrain(.centerX, constant: 0, toItem: view)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 5.0
        image.constrain(.width, constant: 0, toItem: view)
        // image.constrain(.height, constant: 393/2)
        
        gestureRec?.isEnabled = true
    }
    
    func bar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = UIColor.gray
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.constrain(.height, constant: 1)
        bar.constrain(.width, constant: 40)
        return bar
    }
    
    func pan(_ sender:UIPanGestureRecognizer){
        switch sender.state {
        case .ended:
            state.stop(gestureRec!)
            
            let swipeDirection = state.getSwipeDirection()
            if (!state.meetsDragRequirements(swipeDirection)) {
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
