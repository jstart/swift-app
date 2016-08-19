//
//  CardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import Alamofire

class CardViewController : UIViewController, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {
    var delegate : CardDelegate?
    
    var gestureRec : UIPanGestureRecognizer?
    var tapRec : UITapGestureRecognizer?

    var state = SwipeState()
    var control = QuickPageControl(categories: [.connections, .experience, .education, .skills, .events])
    var card : Card?
    var viewPager : ViewPager?
    let image : UIImageView =  UIImageView(image: #imageLiteral(resourceName: "profile_sample"))
    let overlayView : UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.0
        overlayView.isHidden = true
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.layer.cornerRadius = 5.0
        return overlayView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        
        gestureRec = UIPanGestureRecognizer(target: self, action: #selector(pan))
        gestureRec?.delegate = self
        tapRec = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(gestureRec!)
        view.addGestureRecognizer(tapRec!)
    
        let quickViewStack = UIStackView(arrangedSubviews: [bar(), control.stack!, bar()])
        quickViewStack.distribution = .fillProportionally
        quickViewStack.alignment = .center
        quickViewStack.spacing = 5
        
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
        
        view.addSubview(topStack)
        
        viewPager!.scroll.translatesAutoresizingMaskIntoConstraints = false
        viewPager!.scroll.constrain(.width, toItem: view)

        name.constrain(.leading, toItem: position)
        
        topStack.translatesAutoresizingMaskIntoConstraints = false
        topStack.constrain(.top, .width, toItem: view)
        topStack.constrain(.bottom, constant: -10, toItem: view)
        
        quickViewStack.translatesAutoresizingMaskIntoConstraints = false
        quickViewStack.constrain(.height, constant: 30)
        quickViewStack.constrain(.width, .centerX, toItem: view)
        
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 5.0
        image.translatesAutoresizingMaskIntoConstraints = false
        image.constrain(.width, toItem: view)
        
        view.addSubview(overlayView)
        overlayView.constrain(.width, .height, .centerX, .centerY, toItem: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overlayView.alpha = 0.0
        overlayView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismiss(animated: true, completion: nil)
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
        if otherGestureRecognizer.isMember(of: UITapGestureRecognizer.self){
            return false
        }
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
    
    func tap(sender: UITapGestureRecognizer) {
        let details = CardDetailViewController()
        details.control.selectIndex(control.previousIndex)
        details.modalPresentationStyle = .overCurrentContext
        details.transitioningDelegate = self

        present(details, animated: true, completion: nil)
    }
    
    func pan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .ended:
            state.stop(gestureRec!)
            
            let swipeDirection = state.getSwipeDirection()
            if (!state.meetsDragRequirements(swipeDirection) &&
                !state.meetsFlingRequirements(swipeDirection)) {
                // Back to center
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.center = (self.view?.superview?.center)!
                    sender.view?.transform = CGAffineTransform.identity
                    self.overlayView.alpha = 0.0
                    self.overlayView.isHidden = true
                })
                return
            }
            switch swipeDirection {
            case UISwipeGestureRecognizerDirection.up:
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.y = -800
                    }, completion: { _ in
                        self.removeSelf(direction: .up)
                })
                break
            case UISwipeGestureRecognizerDirection.left:
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.x = -800
                    }, completion: { _ in
                        self.removeSelf(direction: .left)
                })
                break
            case UISwipeGestureRecognizerDirection.right:
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.x = 800
                    }, completion: { _ in
                        self.removeSelf(direction: .right)
                })
                break
            case UISwipeGestureRecognizerDirection.down:
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.y = 800
                    }, completion: { _ in
                        self.removeSelf(direction: .down)
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
            overlayView.isHidden = false
            return;
        case .changed :
            state.drag(gestureRec!)
            let translation = sender.translation(in: view)
            sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
            if state.draggingInCurrentDirectionAllowed(){
                animateOverlay(direction: state.getSwipeDirection(), translation: translation)
            }
            sender.setTranslation(.zero, in: view)
        default: break
        }
    }
    
    func removeSelf(direction : UISwipeGestureRecognizerDirection) {
        view.removeFromSuperview()
        removeFromParentViewController()
        delegate?.swiped(direction)
    }
    
    func animateOverlay(direction: UISwipeGestureRecognizerDirection, translation: CGPoint){
        switch direction {
        case UISwipeGestureRecognizerDirection.up:
            overlayView.alpha = min(1, ((view.superview!.center.y - view.center.y)/200)) * 0.75
        case UISwipeGestureRecognizerDirection.down:
            overlayView.alpha = min(1, ((view.center.y - view.superview!.center.y)/200)) * 0.75
        case UISwipeGestureRecognizerDirection.left:
            let progress = min(1, ((view.superview!.center.x - view.center.x)/200)) * 10
            view.transform = CGAffineTransform(rotationAngle:(-progress * CGFloat(M_PI)) / 180)
            if view.center.x <= view.superview!.center.x {
                overlayView.alpha = min(1, ((view.superview!.center.x - view.center.x)/200)) * 0.75
            } else {
                overlayView.alpha = min(1, ((view.center.x - view.superview!.center.x)/200)) * 0.75
            }
        case UISwipeGestureRecognizerDirection.right:
            let progress = min(1, ((view.center.x - view.superview!.center.x)/200)) * 10
            view.transform = CGAffineTransform(rotationAngle:(progress * CGFloat(M_PI)) / 180)
            if view.center.x >= view.superview!.center.x {
                overlayView.alpha = min(1, ((view.center.x - view.superview!.center.x)/200)) * 0.75
            } else {
                overlayView.alpha = min(1, ((view.superview!.center.x - view.center.x)/200)) * 0.75
            }
        default:
            return
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = CardDetailTransition()
        transition.cardVC = self
        transition.presenting = true
            
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = CardDetailTransition()
        transition.presenting = false
        return transition
    }
    
}
