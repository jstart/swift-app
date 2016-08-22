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
    let control = QuickPageControl(categories: [.connections, .experience, .education, .skills, .events])
    let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var controllers = [UserDetailTableViewController]()
    var delegate : QuickPageControlDelegate?
    var transistionToIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        view.backgroundColor = .white
        
        tapRec = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tapRec!)
        
        for (index, category) in [QuickViewCategory.connections, QuickViewCategory.experience, QuickViewCategory.education, QuickViewCategory.skills, QuickViewCategory.events].enumerated() {
            let table = UserDetailTableViewController()
            table.category = category
            table.details = []
            table.index = index
            controllers.append(table)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(control.stack!)
        control.stack!.translatesAutoresizingMaskIntoConstraints = false
        control.stack!.constrain(.top, constant: 5, toItem: view)
        control.stack!.constrain(.width, constant: -80, toItem: view)
        control.stack!.constrain(.leading, constant: 40, toItem: view)
        control.stack!.constrain(.trailing, constant: -40, toItem: view)
        control.stack!.constrain(.centerX, toItem: view)
        control.stack!.constrain(.height, constant: 40)
        control.delegate = self
        control.selectIndex(control.previousIndex)
        
        pageController.delegate = self
        pageController.dataSource = self
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: pageController.view, attribute: .top, relatedBy: .equal, toItem: control.stack!, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        pageController.view.constrain(.width, .centerX, .bottom, toItem: view)
        
        pageController.setViewControllers([controllers[control.previousIndex]], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let table = viewController as! UserDetailTableViewController
        let index = table.index!
        if index == 0 {
            return nil
        }

        return controllers[index - 1]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let table = viewController as! UserDetailTableViewController
        let index = table.index!
        if index == controllers.count - 1 {
            return nil
        }
        
        return controllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed {
            control.selectIndex(transistionToIndex)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let table = pendingViewControllers.first! as! UserDetailTableViewController
        transistionToIndex = table.index!
    }
    
    func selectedIndex(_ index:Int) {
        if index == control.previousIndex {
            return
        }
        delegate?.selectedIndex(index)
        pageController.setViewControllers([controllers[index]], direction: (control.previousIndex < index) ? .forward : .reverse, animated: true, completion: nil)
    }
    
    func tap(sender:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
