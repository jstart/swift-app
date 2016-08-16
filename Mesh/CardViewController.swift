//
//  CardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import Alamofire

class CardViewController : UIViewController, UIGestureRecognizerDelegate {
    var delegate : CardDelegate?
    
    var gestureRec : UIPanGestureRecognizer?
    var state = SwipeState()
    var control = QuickPageControl(categories: [.connections, .education, .experience, .skills, .events])
    var card : Card?
    var viewPager : ViewPager?
    let image : UIImageView =  UIImageView(image: #imageLiteral(resourceName: "profile_sample"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        
        gestureRec = UIPanGestureRecognizer(target: self, action: #selector(pan))
        gestureRec?.delegate = self
        gestureRec?.isEnabled = false
        view.addGestureRecognizer(gestureRec!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let quickViewStack = UIStackView(arrangedSubviews: [bar(), control.stack!, bar()])
        quickViewStack.distribution = .fillProportionally
        quickViewStack.alignment = .center
        quickViewStack.spacing = 10
        
        viewPager = ViewPager(views: QuickViewGenerator.viewsForDetails(userDetails: card!.person!.details))
        viewPager?.scroll.panGestureRecognizer.require(toFail: gestureRec!)
        control.delegate = viewPager!
        viewPager?.delegate = control
        control.selectIndex(0)
        
        let name = UILabel()
        name.textColor = .black
        name.text = "Micha Kaufman"
        name.constrain(.height, constant: 20)
        
        let position = UILabel()
        position.textColor = .black
        position.text = "VP of Engineering at Tesla"
        position.constrain(.height, constant: 20)

        let topStack = UIStackView(arrangedSubviews: [image, name, position, quickViewStack, viewPager!.scroll])
        topStack.axis = .vertical
        topStack.distribution = .fillProportionally
        topStack.alignment = .center
        topStack.spacing = 10
        
        view.addSubview(topStack)
        viewPager!.scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: viewPager!.scroll, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100).isActive = true
        viewPager!.scroll.constrain(.width, toItem: view)

        name.constrain(.leading, toItem: position)
        
        topStack.translatesAutoresizingMaskIntoConstraints = false
        topStack.constrain(.top, toItem: view)
        topStack.constrain(.height, constant: 0, toItem: view)
        topStack.constrain(.width, constant: 0, toItem: view)
        
        quickViewStack.translatesAutoresizingMaskIntoConstraints = false
        quickViewStack.constrain(.height, constant: 50)
        quickViewStack.constrain(.width, constant: 0, toItem: view)
        quickViewStack.constrain(.centerX, constant: 0, toItem: view)
        
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 5.0
        image.translatesAutoresizingMaskIntoConstraints = false
        image.constrain(.width, constant: 0, toItem: view)
        
        //let companyLogo = UIImageView(image: #imageLiteral(resourceName: "settings"))
        //name.addSubview(companyLogo)
        
        gestureRec?.isEnabled = true
    }
    
    func pagerView(_ color : UIColor) -> UIView {
        let pagerView = UIView()
        pagerView.isUserInteractionEnabled = false
        pagerView.backgroundColor = color
        
        pagerView.translatesAutoresizingMaskIntoConstraints = false
        pagerView.constrain(.height, constant: 30)
        return pagerView
    }
    
    func bar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = UIColor.gray
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.constrain(.height, constant: 1)
        bar.constrain(.width, constant: 80)
        return bar
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print(gestureRecognizer, otherGestureRecognizer)
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: gestureRecognizer.view)
        let subview = gestureRec?.view?.hitTest(touchPoint, with: nil)
        if (subview?.isDescendant(of: viewPager!.scroll))! {
            return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func pan(_ sender: UIPanGestureRecognizer){
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
            //sender.view?.transform = CGAffineTransform(rotationAngle: CGFloat(180.0) / CGFloat(M_PI))

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
