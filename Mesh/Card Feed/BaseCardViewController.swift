//
//  BaseCardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class BaseCardViewController : UIViewController, UIGestureRecognizerDelegate {
    var rec : RecommendationResponse?

    var delegate : CardDelegate?
    var state = SwipeState()

    var gestureRec : UIPanGestureRecognizer?
    var tapRec : UITapGestureRecognizer?
    let overlayView  = UIView(translates: false).then {
        $0.alpha = 1.0
        $0.layer.cornerRadius = 10.0
    }
    let leftLabel = UILabel(translates: false).then {
        $0.text = "PASS"
        $0.font = .boldProxima(ofSize: 25); $0.textColor = .white
        $0.textAlignment = .center
        $0.constrain((.height, 25))
    }
    let leftIcon = UIImageView(translates: false).then {
        $0.image = #imageLiteral(resourceName: "pass_stamp")
        $0.contentMode = .scaleAspectFit
        $0.constrain(.height, .width, constant: 55)
    }
    let leftStamp = UIStackView(translates: false).then { $0.axis = .vertical; $0.spacing = 15 }
    
    let rightIcon = UIImageView(translates: false).then {
        $0.image = #imageLiteral(resourceName: "like_stamp")
        $0.contentMode = .scaleAspectFit
        $0.constrain(.height, .width, constant: 55)
    }
    let rightLabel = UILabel(translates: false).then {
        $0.text = "LIKE"
        $0.font = .boldProxima(ofSize: 25); $0.textColor = .white
        $0.textAlignment = .center
        $0.constrain((.height, 25))
    }
    let rightStamp = UIStackView(translates: false).then { $0.axis = .vertical; $0.spacing = 15 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 10.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 5
        view.backgroundColor = .white
        
        gestureRec = UIPanGestureRecognizer(target: self, action: #selector(pan))
        gestureRec?.delegate = self
        tapRec = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(gestureRec!); view.addGestureRecognizer(tapRec!)
    
        view.addSubview(overlayView)
        overlayView.constrain(.width, .height, .centerX, .centerY, toItem: view)
        
        rightStamp.addArrangedSubview(rightIcon); rightStamp.addArrangedSubview(rightLabel)
        leftStamp.addArrangedSubview(leftIcon); leftStamp.addArrangedSubview(leftLabel)
        [leftIcon, leftLabel, rightIcon, rightLabel].forEach({ $0.layer.shadowColor = UIColor.darkGray.cgColor; $0.layer.shadowOpacity = 1.0; $0.layer.shadowRadius = 5; $0.layer.shadowOffset = .zero })
        
        overlayView.addSubviews(leftStamp, rightStamp)
        leftStamp.constrain(.centerX, .centerY, .width, toItem: overlayView); rightStamp.constrain(.centerX, .centerY, .width, toItem: overlayView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubview(toFront: overlayView)
        overlayView.alpha = 0.0
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { return true }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool { return true }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool { return false }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool { return false }
    
    func tap(_ sender: UITapGestureRecognizer) { }
    
    func pan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
            
        case .ended:
            state.stop(gestureRec!)
            
            let swipeDirection = state.getSwipeDirection()
            if ((!state.meetsDragRequirements(swipeDirection) &&
                !state.meetsFlingRequirements(swipeDirection)) ||
                !state.meetsPositionRequirements(swipeDirection)) {
                // Back to center
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.center = (self.view?.superview?.center)!
                    sender.view?.transform = CGAffineTransform.identity
                    self.overlayView.alpha = 0.0
                    self.delegate?.swiping(percent: 0)
                    self.overlayView.isHidden = true
                })
                return
            }
            UIView.animate(withDuration: 0.2, animations: {
            switch swipeDirection {
            case UISwipeGestureRecognizerDirection.up:
                    self.delegate?.swiping(percent: 100)
                    sender.view?.frame.origin.y = -sender.view!.superview!.frame.height; break
            case UISwipeGestureRecognizerDirection.left:
                    self.delegate?.swiping(percent: 100)
                    sender.view?.frame.origin.x = -sender.view!.superview!.frame.width - 50; break
            case UISwipeGestureRecognizerDirection.right:
                    self.delegate?.swiping(percent: 100)
                    sender.view?.frame.origin.x = sender.view!.superview!.frame.width + 100; break
            case UISwipeGestureRecognizerDirection.down:
                    self.delegate?.swiping(percent: 100)
                    sender.view?.frame.origin.y = sender.view!.superview!.frame.height; break
            default: sender.view?.center = (self.view?.superview?.center)!; break }
                }, completion: { _ in
                    self.removeSelf(swipeDirection) }); break
        case .cancelled : fallthrough
        case .failed :
            // Back to center
            UIView.animate(withDuration: 0.2, animations: {
                self.delegate?.swiping(percent: 0)
                sender.view?.center = (self.view?.superview?.center)!
            })
            break
        case .began :
            state.start(gestureRec!)
            overlayView.isHidden = false
            rightStamp.alpha = 0; leftStamp.alpha = 0
            return;
        case .changed :
            state.drag(gestureRec!)
            let translation = sender.translation(in: view)
            sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
            if state.draggingInCurrentDirectionAllowed() {
                animateOverlay(state.getSwipeDirection())
            }
            sender.setTranslation(.zero, in: view)
        default: break }
    }
    
    func removeSelf(_ direction : UISwipeGestureRecognizerDirection) {
        viewWillDisappear(true); viewDidDisappear(true)
        presentingViewController?.dismiss()
        view.removeFromSuperview()
        delegate?.swiped(direction)
    }
    
    func animateOverlay(_ direction: UISwipeGestureRecognizerDirection) {
        if state.meetsPositionRequirements(direction) {
            rightStamp.alpha = direction == .right ? 1.0 : 0; leftStamp.alpha = direction == .left ? 1.0 : 0
        }
        var overlayAlpha : CGFloat = 0
        var screenProgress : CGFloat = 0
        switch direction {
        case UISwipeGestureRecognizerDirection.up:
            screenProgress = view.superview!.center.y - view.center.y
            overlayAlpha = min(1, (screenProgress/50))
        case UISwipeGestureRecognizerDirection.down:
            screenProgress = view.center.y - view.superview!.center.y
            overlayAlpha = min(1, (screenProgress/50))
        case UISwipeGestureRecognizerDirection.left:
            screenProgress = view.center.x - view.superview!.center.x
            let progress = min(1, (screenProgress/200)) * 10
            view.transform = CGAffineTransform(rotationAngle:(progress * CGFloat(M_PI)) / 180)
            if view.center.x <= view.superview!.center.x {
                overlayAlpha = min(1, ((view.superview!.center.x - view.center.x)/50))
            } else {
                overlayAlpha = min(1, (screenProgress/50))
            }
        case UISwipeGestureRecognizerDirection.right:
            screenProgress = view.center.x - view.superview!.center.x
            let progress = min(1, (screenProgress/200)) * 10
            view.transform = CGAffineTransform(rotationAngle:(progress * CGFloat(M_PI)) / 180)
            if view.center.x >= view.superview!.center.x {
                overlayAlpha = min(1, (screenProgress/50))
            } else {
                overlayAlpha = min(1, ((view.superview!.center.x - view.center.x)/50))
            }
        default: return }
        delegate?.swiping(percent: min(1, (screenProgress/100)))
        overlayView.alpha = overlayAlpha
    }
    
}
