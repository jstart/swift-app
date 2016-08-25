//
//  CardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import Alamofire

class CardViewController : UIViewController, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, QuickPageControlDelegate {
    var delegate : CardDelegate?
    
    var gestureRec : UIPanGestureRecognizer?
    var tapRec : UITapGestureRecognizer?

    var state = SwipeState()
    var control = QuickPageControl(categories: [.connections, .experience, .education, .skills, .events])
    var card : Card?
    var viewPager : ViewPager?
    let imageView : UIImageView = UIImageView(image: #imageLiteral(resourceName: "profile_sample"))
    let transition = CardDetailTransition()
    
    let overlayView  = UIView().then {
        $0.backgroundColor = .black
        $0.alpha = 0.0
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 5.0
    }
    
    let name = UILabel()
    let position = UILabel()

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
    
        let quickViewStack = UIStackView(arrangedSubviews: [bar(), control.stack!, bar()])
        quickViewStack.distribution = .fillProportionally
        quickViewStack.alignment = .center
        quickViewStack.spacing = 10
        
        viewPager = ViewPager(views: QuickViewGenerator.viewsForDetails(card?.person?.details))
        viewPager?.scroll.panGestureRecognizer.require(toFail: gestureRec!)
        control.delegate = viewPager!
        viewPager?.delegate = control
        control.selectIndex(0)
        
        name.textColor = .black
        name.backgroundColor = .white
        name.font = UIFont.systemFont(ofSize: 20)
        name.text = card?.person?.user?.first_name != nil ? card!.person!.user!.first_name! : "Micha Kaufman"
        name.constrain(.height, constant: 20)
        
        position.textColor = #colorLiteral(red: 0.7810397744, green: 0.7810582519, blue: 0.7810482979, alpha: 1)
        position.backgroundColor = .white
        position.font = UIFont.systemFont(ofSize: 16)
        position.text = "VP of Engineering at Tesla"
        position.constrain(.height, constant: 20)

        let topStack = UIStackView(arrangedSubviews: [imageView, name, position, quickViewStack, viewPager!.scroll])
        topStack.axis = .vertical
        topStack.distribution = .fillProportionally
        topStack.alignment = .fill
        
        view.addSubview(topStack)
        
        viewPager!.scroll.translatesAutoresizingMaskIntoConstraints = false
        viewPager!.scroll.backgroundColor = .white
        viewPager!.scroll.constrain(.width, toItem: view)

        name.constrain(.leading, toItem: position)
        
        NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: name, attribute: .top, multiplier: 1.0, constant: -11).isActive = true
        NSLayoutConstraint(item: position, attribute: .bottom, relatedBy: .equal, toItem: quickViewStack, attribute: .top, multiplier: 1.0, constant: -8).isActive = true

        topStack.translatesAutoresizingMaskIntoConstraints = false
        topStack.constrain(.top, .width, toItem: view)
        topStack.constrain(.bottom, constant: -10, toItem: view)
        
        quickViewStack.translatesAutoresizingMaskIntoConstraints = false
        quickViewStack.constrain(.height, constant: 30)
        quickViewStack.constrain(.width, .centerX, toItem: view)
        
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.constrain(.width, .centerX, toItem: view)
        
        let logo = UIImageView(image: #imageLiteral(resourceName: "tesla"))
        view.addSubview(logo)
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.constrain(.width, .height, constant: 62)
        logo.constrain(.leading, constant: 15, toItem: view)
        logo.constrain(.bottom, constant: 62 - 15, toItem: imageView)

        NSLayoutConstraint(item: name, attribute: .leading, relatedBy: .equal, toItem: logo, attribute: .trailing, multiplier: 1.0, constant: 15).isActive = true
        NSLayoutConstraint(item: position, attribute: .leading, relatedBy: .equal, toItem: logo, attribute: .trailing, multiplier: 1.0, constant: 15).isActive = true

        view.addSubview(overlayView)
        overlayView.constrain(.width, .height, .centerX, .centerY, toItem: view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var rect = imageView.bounds
        rect.size.width = view.frame.size.width
        rect.size.height = imageView.frame.size.height + 100
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 5.0, height: 5.0))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.path = maskPath.cgPath
        
        imageView.layer.mask = maskLayer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLayoutSubviews()
        overlayView.alpha = 0.0
        overlayView.isHidden = true
        
        control.selectIndex(0)
        viewPager?.selectedIndex(0)
        
        name.text = card?.person?.user?.first_name != nil ? card!.person!.user!.first_name! + " " + card!.person!.user!.last_name! : "Micha Kaufman"
        position.text = card?.person?.user?.title != nil ? card!.person!.user!.title! : "VP of Engineering at Tesla"
        
        guard let user = card?.person?.user else {
            return
        }
        URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue()).dataTask(with: URL(string: user.photos!.large!)!, completionHandler: {data, response, error in
            DispatchQueue.global().async {
                let image = UIImage(data: data!)
                DispatchQueue.main.sync {
                    if image != nil {
                        self.imageView.image = image
                    } else {
                        self.imageView.image = #imageLiteral(resourceName: "profile_sample")
                    }
                }
            }
        }).resume()
    }
    
    func bar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.constrain(.height, constant: 1)
        NSLayoutConstraint(item: bar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80).isActive = true
        //NSLayoutConstraint(item: bar, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40).isActive = true

        return bar
    }
    
    func selectedIndex(_ index: Int) {
        control.selectIndex(index)
        viewPager?.selectedIndex(index)
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
    
    func tap(_ sender: UITapGestureRecognizer) {
        let details = CardDetailViewController()
        details.delegate = self
        details.transistionToIndex = control.previousIndex
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
                animateOverlay(state.getSwipeDirection(), translation: translation)
            }
            sender.setTranslation(.zero, in: view)
        default: break
        }
    }
    
    func removeSelf(_ direction : UISwipeGestureRecognizerDirection) {
        viewWillDisappear(true)
        viewDidDisappear(true)
        if presentingViewController != nil {
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
        delegate?.swiped(direction)
    }
    
    func animateOverlay(_ direction: UISwipeGestureRecognizerDirection, translation: CGPoint){
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
        transition.cardVC = self
        transition.presenting = true
            
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.cardVC = self
        transition.presenting = false
        return transition
    }
    
}
