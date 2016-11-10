//
//  PersonCardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import AlamofireImage
import RealmSwift

class PersonCardViewController : BaseCardViewController, UIViewControllerTransitioningDelegate, QuickPageControlDelegate {
    
    let control = QuickPageControl(categories: [.connections, .experience, .education, .skills, .events])
    var viewPager : ViewPager?
    let transition = CardDetailTransition()
    let imageView = UIImageView(image: .imageWithColor(.gray)).then {
        $0.clipsToBounds = true; $0.contentMode = .scaleAspectFill; $0.translates = false
        $0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
    }
    let name = UILabel(translates: false).then {
        $0.textColor = .black; $0.font = UIFont.gothamBold(ofSize: 20); $0.backgroundColor = .white; $0.constrain(.height, constant: 22)
    }
    let position = UILabel(translates: false).then {
        $0.textColor = #colorLiteral(red: 0.7810397744, green: 0.7810582519, blue: 0.7810482979, alpha: 1); $0.font = UIFont.gothamBook(ofSize: 16); $0.backgroundColor = .white; $0.constrain(.height, constant: 20)
    }
    let logo = UIImageView(image: .imageWithColor(.gray)).then {
        $0.translates = false; $0.backgroundColor = .white
        $0.clipsToBounds = true; $0.contentMode = .scaleAspectFit; $0.layer.cornerRadius = 5.0
        $0.constrain(.width, .height, constant: 62)
    }
    let logoBackshadow = UIView(translates: false).then {
        $0.backgroundColor = .white; $0.layer.cornerRadius = 5.0
        $0.layer.shadowColor = UIColor.black.cgColor; $0.layer.shadowOpacity = 0.2; $0.layer.shadowRadius = 10
        $0.constrain(.width, .height, constant: 62)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        transition.cardVC = self
        gestureRec?.delegate = self
        let quickViewStack = UIStackView(bar(), control.stack!, bar())
        quickViewStack.distribution = .fillProportionally
        quickViewStack.alignment = .center
        
        viewPager = ViewPager(views: [])
        viewPager?.scroll.panGestureRecognizer.require(toFail: gestureRec!)
        viewPager?.scroll.backgroundColor = .white
        control.delegate = viewPager!
        viewPager?.delegate = control
        if let user = rec?.user {
            let quickViews = QuickViewGenerator.viewsForDetails(UserDetails(connections: [], experiences: Array(user.companies), educationItems: Array(user.schools), skills: Array(user.interests), events: []))
            viewPager?.insertViews(quickViews)
            if let category = user.promoted_category {
                let categoryIndex = QuickViewCategory.index(category)
                control.selectIndex(categoryIndex)
                viewPager?.selectedIndex(categoryIndex, animated: true)
            }
        } else {
            control.selectIndex(0)
            viewPager?.selectedIndex(0, animated: false)
        }

        let namePositionContainer = UIView().then { $0.backgroundColor = .white }
        
        namePositionContainer.addSubviews(name, position)
        
        let bottomStack = UIStackView(namePositionContainer, quickViewStack, viewPager!.scroll, axis: .vertical)
        bottomStack.distribution = .fillProportionally
        bottomStack.alignment = .fill
        bottomStack.constrain((.height, 200))
        
        let topStack = UIStackView(imageView, bottomStack, axis: .vertical)
        topStack.distribution = .fillProportionally
        topStack.alignment = .fill
        
        view.addSubview(topStack)
        
        viewPager!.scroll.translates = false
        viewPager!.scroll.backgroundColor = .white
        viewPager!.scroll.constrain(.width, .centerX, toItem: view)

        imageView.constrain(.bottom, constant: -11, toItem: name, toAttribute: .top)
        imageView.constrain(.height, relatedBy: .equal, toItem: view, multiplier: 660/1052)
        
        //imageView.constrain(.height, relatedBy: .greaterThanOrEqual, constant: 80)

        topStack.translates = false
        topStack.constrain(.top, .width, toItem: view)
        topStack.constrain(.bottom, constant: -10, toItem: view)
        
        quickViewStack.translates = false
        quickViewStack.constrain(.height, constant: 30)
        quickViewStack.constrain(.width, .centerX, toItem: view)
        
        imageView.constrain(.width, .centerX, toItem: view)
        
        view.addSubview(logoBackshadow)
        view.addSubview(logo)
        
        logo.constrain(.width, .height, constant: 62)
        logo.constrain(.leading, constant: 15, toItem: view)
        logo.constrain(.bottom, constant: 62 - 15, toItem: imageView)
        
        logoBackshadow.constrain(.width, .height, constant: 62)
        logoBackshadow.constrain(.leading, constant: 15, toItem: view)
        logoBackshadow.constrain(.bottom, constant: 62 - 15, toItem: imageView)

        name.constrain(.top, constant: 11, toItem: namePositionContainer)
        name.constrain(.leading, constant: 15, toItem: logo, toAttribute: .trailing)
        name.constrain(.trailing, toItem: namePositionContainer, toAttribute: .trailingMargin)
        
        position.constrain(.leading, .trailing, toItem: name)
        position.constrain(.top, constant: 0, toItem: name, toAttribute: .bottom)
        position.constrain(.bottom, constant: -8, toItem: namePositionContainer)

        view.addSubview(overlayView)
        overlayView.constrain(.width, .height, .centerX, .centerY, toItem: view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.layer.mask = nil
        imageView.layoutIfNeeded()
        
        var rect = imageView.bounds
        rect.size.width = view.frame.size.width * (view.transform.d == CardFeedViewConfig().behindScale ? 2 : 1)
        rect.size.height = imageView.frame.size.height + 100
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10.0, height: 10.0))
        
        imageView.layer.mask = CAShapeLayer().then { $0.frame = rect; $0.path = maskPath.cgPath }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overlayView.alpha = 0.0
        overlayView.isHidden = true
        
        if let user = rec?.user, let category = user.promoted_category {
            let categoryIndex = QuickViewCategory.index(category)
            control.selectIndex(categoryIndex)
            viewPager?.selectedIndex(categoryIndex, animated: true)
        } else {
            control.selectIndex(0)
            viewPager?.selectedIndex(0, animated: false)
        }
        
        name.text = rec?.user?.fullName() ?? ""
        position.text = rec?.user?.fullTitle() ?? ""
        
        guard let largeURL = rec?.user?.photos?.large else { imageView.image = .imageWithColor(.gray); return }
        imageView.af_setImage(withURL: URL(string: largeURL)!)
        
        guard let companyURL = rec?.user?.companies.first?.logo else { return }
        logo.af_setImage(withURL: URL(string: companyURL)!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = rec?.user, let category = user.promoted_category {
            let categoryIndex = QuickViewCategory.index(category)
            control.selectIndex(categoryIndex)
            viewPager?.selectedIndex(categoryIndex, animated: true)
        } else {
            control.selectIndex(0)
            viewPager?.selectedIndex(0, animated: false)
        }
    }
    
    func bar() -> UIView {
        return UIView(translates: false).then {
            $0.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
            $0.constrain(.height, constant: 1)
            $0.constrain(.width, relatedBy: .lessThanOrEqual, constant: 80)
            let greater = $0.constraint(.width, relatedBy: .greaterThanOrEqual, constant: 40)
            greater.priority = UILayoutPriorityDefaultHigh; greater.isActive = true
        }
    }
    
    func selectedIndex(_ index: Int, animated: Bool) { control.selectIndex(index); viewPager?.selectedIndex(index) }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !otherGestureRecognizer.isMember(of: UITapGestureRecognizer.self)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: gestureRecognizer.view)
        let subview = gestureRec?.view?.hitTest(touchPoint, with: nil)
        return !(subview?.isDescendant(of: viewPager!.scroll))!
    }
    
    override func tap(_ sender: UITapGestureRecognizer) {
        let details = CardDetailViewController()
        guard let user = rec?.user else { return }
        details.details = UserDetails(connections: [], experiences: Array(user.companies), educationItems: Array(user.schools), skills: Array(user.interests), events: [])
        details.delegate = self
        details.transistionToIndex = control.previousIndex
        details.control.selectIndex(control.previousIndex)
        details.modalPresentationStyle = .overCurrentContext
        details.transitioningDelegate = self

        present(details, animated: true, completion: nil)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true; return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false; return transition
    }
//    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        transition.cardVC = self
//        transition.presenting = true
//        //TODO: return transition
//    }
//    
//    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        transition.cardVC = self
//        transition.presenting = false
//        return transition
//    }
    
}
