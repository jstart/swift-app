//
//  CardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import TwitterKit

class TweetCardViewController : UIViewController, UIGestureRecognizerDelegate {
    var delegate : CardDelegate?
    var state = SwipeState()

    var gestureRec : UIPanGestureRecognizer?
    var tapRec : UITapGestureRecognizer?
    let overlayView  = UIView().then {
        $0.backgroundColor = .black
        $0.alpha = 0.0
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 5.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 5
        view.backgroundColor = .white
        //view.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        gestureRec = UIPanGestureRecognizer(target: self, action: #selector(pan))
        gestureRec?.delegate = self
        tapRec = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(gestureRec!)
        view.addGestureRecognizer(tapRec!)
    
        view.addSubview(overlayView)
        overlayView.constrain(.width, .height, .centerX, .centerY, toItem: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overlayView.alpha = 0.0
        overlayView.isHidden = true
        TWTRAPIClient().loadTweet(withID: "631879971628183552") { (tweet, error) in
            guard let unwrappedTweet = tweet else {
                print("Tweet load error:\(error!.localizedDescription)")
                return
            }
            let tweetView = TWTRTweetView(tweet: unwrappedTweet)
            tweetView.presenterViewController = self
            self.view.addSubview(tweetView)
            tweetView.translatesAutoresizingMaskIntoConstraints = false
            tweetView.constrain(.width, .centerX, .centerY, toItem: self.view)
            self.view.bringSubview(toFront: self.overlayView)
        }
    }
    
    func tap(_ sender: UITapGestureRecognizer) {
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
                        self.removeSelf(.up)
                })
                break
            case UISwipeGestureRecognizerDirection.left:
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.x = -800
                    }, completion: { _ in
                        self.removeSelf(.left)
                })
                break
            case UISwipeGestureRecognizerDirection.right:
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.x = 800
                    }, completion: { _ in
                        self.removeSelf(.right)
                })
                break
            case UISwipeGestureRecognizerDirection.down:
                UIView.animate(withDuration: 0.2, animations: {
                    sender.view?.frame.origin.y = 800
                    }, completion: { _ in
                        self.removeSelf(.down)
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
                animateOverlay(state.getSwipeDirection())
            }
            sender.setTranslation(.zero, in: view)
        default: break
        }
    }
    
    func removeSelf(_ direction : UISwipeGestureRecognizerDirection) {
        viewWillDisappear(true)
        viewDidDisappear(true)
        presentingViewController?.dismiss()
        delegate?.swiped(direction)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
    
    func animateOverlay(_ direction: UISwipeGestureRecognizerDirection){
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
    
}
