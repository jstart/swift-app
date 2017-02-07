//
//  CardDetailViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class CardDetailViewController : UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, QuickPageControlDelegate {
    
    var tapRec : UITapGestureRecognizer?
    var details : UserDetails?
    let control = QuickPageControl(categories: [.connections, .experience, .education, .skills, .events])
    let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil).then {
        $0.view.translates = false
    }
    var controllers = [UserDetailTableViewController]()
    var delegate : QuickPageControlDelegate?
    var transistionToIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.layer.cornerRadius = 10.0
//        view.layer.shadowColor = UIColor.lightGray.cgColor
//        view.layer.shadowOpacity = 0.5
        view.backgroundColor = .white
        
        tapRec = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tapRec!)
        
        for (index, category) in [QuickViewCategory.connections, QuickViewCategory.experience, QuickViewCategory.education, QuickViewCategory.skills, QuickViewCategory.events].enumerated() {
            let table = UserDetailTableViewController()
            table.category = category
            table.details = details!.details(forIndex: index)
            table.index = index
            table.dismissHandler = {
                self.presentingViewController?.dismiss()
            }
            controllers.append(table)
        }
        
        view.addSubview(control.stack!)

        control.stack!.constrain((.top, 5), (.width, -160), (.centerX, 0), toItem: view)
        control.stack!.constrain((.height, 40))
        
        control.delegate = self
        control.selectIndex(control.previousIndex)
        
        let separator = UIView(translates: false)
        separator.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        view.addSubview(separator)
        separator.constrain(.width, .centerX, toItem: view)
        separator.constrain((.height, 1))
        separator.constrain(.top, constant: 2, toItem: control.stack!, toAttribute: .bottom)
        
        pageController.delegate = self
        pageController.dataSource = self
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        pageController.view.constrain(.top, constant: 3, toItem: control.stack!, toAttribute: .bottom)
        pageController.view.constrain(.width, .centerX, .bottom, toItem: view)
        
        pageController.setViewControllers([controllers[control.previousIndex]], direction: .forward, animated: false, completion: nil)
        view.bringSubview(toFront: separator)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.dismiss(animated: false)
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let table = viewController as! UserDetailTableViewController
        let index = table.index!
        if index == 0 { return nil }

        return controllers[index - 1]
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let table = viewController as! UserDetailTableViewController
        let index = table.index!
        if index == controllers.count - 1 { return nil }
        
        return controllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed {
            control.selectIndex(transistionToIndex)
            delegate?.selectedIndex(transistionToIndex, animated: true)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let table = pendingViewControllers.first! as! UserDetailTableViewController
        transistionToIndex = table.index!
    }
    
    func selectedIndex(_ index: Int, animated: Bool) {
        if index == control.previousIndex { return }
        delegate?.selectedIndex(index, animated: animated)
        pageController.setViewControllers([controllers[index]], direction: (control.previousIndex < index) ? .forward : .reverse, animated: animated, completion: nil)
    }
    
    func tap(_ sender: UITapGestureRecognizer) { dismiss() }
    
}
