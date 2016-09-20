//
//  PersonCardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import AlamofireImage

class PersonCardViewController : BaseCardViewController, UIViewControllerTransitioningDelegate, QuickPageControlDelegate {
    
    var control = QuickPageControl(categories: [.connections, .experience, .education, .skills, .events])
    var card : Rec?
    var viewPager : ViewPager?
    let imageView = UIImageView(image: .imageWithColor(.gray)).then {
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFill
        $0.translates = false
        $0.layer.borderWidth = 1;
        $0.layer.borderColor = UIColor.clear.cgColor
    }
    let transition = CardDetailTransition()
    
    let name = UILabel(translates: false).then {
        $0.textColor = .black
        $0.backgroundColor = .white
        $0.font = UIFont.proxima(ofSize: 20)
        $0.constrain(.height, constant: 22)
    }
    let position = UILabel(translates: false).then {
        $0.textColor = #colorLiteral(red: 0.7810397744, green: 0.7810582519, blue: 0.7810482979, alpha: 1)
        $0.backgroundColor = .white
        $0.font = UIFont.proxima(ofSize: 16)
        $0.constrain(.height, constant: 20)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 5
        view.backgroundColor = .white
        //view.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        transition.cardVC = self

        gestureRec = UIPanGestureRecognizer(target: self, action: #selector(pan))
        gestureRec?.delegate = self
        tapRec = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(gestureRec!)
        view.addGestureRecognizer(tapRec!)
        
        let quickViewStack = UIStackView(arrangedSubviews: [bar(), control.stack!, bar()])
        quickViewStack.backgroundColor = .white
        quickViewStack.distribution = .fillProportionally
        quickViewStack.alignment = .center
        quickViewStack.spacing = 0
        
        viewPager = ViewPager(views: QuickViewGenerator.viewsForDetails(card?.person?.details))
        viewPager?.scroll.panGestureRecognizer.require(toFail: gestureRec!)
        viewPager?.scroll.backgroundColor = .white
        control.delegate = viewPager!
        viewPager?.delegate = control
        control.selectIndex(0)

        name.text = card?.person?.user?.first_name != nil ? card!.person!.user!.first_name! : "Micha Kaufman"
        position.text = "VP of Engineering at Tesla"

        let namePositionContainer = UIView().then { $0.backgroundColor = .white }
        
        namePositionContainer.addSubviews(name, position)
        
        let bottomStack = UIStackView(arrangedSubviews: [namePositionContainer, quickViewStack, viewPager!.scroll])
        bottomStack.axis = .vertical
        bottomStack.distribution = .fillProportionally
        bottomStack.alignment = .fill
        bottomStack.constrain((.height, 200))
        
        let topStack = UIStackView(arrangedSubviews: [imageView, bottomStack])
        topStack.axis = .vertical
        topStack.distribution = .fillProportionally
        topStack.alignment = .fill
        
        view.addSubview(topStack)
        
        viewPager!.scroll.translates = false
        viewPager!.scroll.backgroundColor = .white
        viewPager!.scroll.constrain(.width, .centerX, toItem: view)

        imageView.constrain(.bottom, constant: -11, toItem: name, toAttribute: .top)

        topStack.translates = false
        topStack.constrain(.top, .width, toItem: view)
        topStack.constrain(.bottom, constant: -10, toItem: view)
        
        quickViewStack.translates = false
        quickViewStack.constrain(.height, constant: 30)
        quickViewStack.constrain(.width, .centerX, toItem: view)
        
        imageView.constrain(.width, .centerX, toItem: view)
        
        let logo = UIImageView(image: #imageLiteral(resourceName: "tesla"))
        view.addSubview(logo)
        
        logo.translates = false
        logo.constrain(.width, .height, constant: 62)
        logo.constrain(.leading, constant: 15, toItem: view)
        logo.constrain(.bottom, constant: 62 - 15, toItem: imageView)

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
        overlayView.alpha = 0.0
        overlayView.isHidden = true
        
        control.selectIndex(0)
        viewPager?.selectedIndex(0, animated: false)
        
        name.text = card?.person?.user?.fullName() ?? "Test Name"
        position.text = card?.person?.user?.fullTitle() ?? "Test Title"
        
        guard let largeURL = card?.person?.user?.photos?.large else { imageView.image = .imageWithColor(.gray); return }
        imageView.alpha = 0
        imageView.af_setImage(withURL: URL(string: largeURL)!, completion: { response in self.imageView.fadeIn() })
    }
    
    func bar() -> UIView {
        return UIView(translates: false).then {
            $0.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
            $0.constrain(.height, constant: 1)
            $0.constrain(.width, relatedBy: .lessThanOrEqual, constant: 80)
            let greater = $0.constraint(.width, relatedBy: .greaterThanOrEqual, constant: 40)
            greater.priority = UILayoutPriorityDefaultHigh
            greater.isActive = true
        }
    }
    
    func selectedIndex(_ index: Int, animated: Bool) {
        control.selectIndex(index)
        viewPager?.selectedIndex(index)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !otherGestureRecognizer.isMember(of: UITapGestureRecognizer.self)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: gestureRecognizer.view)
        let subview = gestureRec?.view?.hitTest(touchPoint, with: nil)
        return !(subview?.isDescendant(of: viewPager!.scroll))!
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func tap(_ sender: UITapGestureRecognizer) {
        let details = CardDetailViewController()
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
