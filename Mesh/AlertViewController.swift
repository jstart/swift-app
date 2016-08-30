//
//  AlertViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/29/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

struct AlertAction {
    var title : String
    var backgroundColor : UIColor
    var titleColor = UIColor.white
    var handler : (() -> Void)
}

class AlertViewController: UIViewController, UIViewControllerTransitioningDelegate {

    var imageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.constrain(.height, .width, constant: 100)
    }
    var titleLabel = UILabel()
    var textLabel = UILabel()
    var actions : [AlertAction]?
    var buttons : [UIButton] = []
    
    convenience init(_ newActions : [AlertAction], image: UIImage = UIImage()) {
        self.init()
        actions = newActions
        imageView.image = image
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.constrain(.width, .height, constant: 325)
        
        view.addSubview(imageView)
        imageView.constrain(.centerX, toItem: view)
        imageView.constrain(.top, constant: 40, toItem: view)
        
        guard let actions = actions else { return }
        for action in actions {
            let button = UIButton()
            button.setTitle(action.title, for: .normal)
            button.setTitleColor(action.titleColor, for: .normal)
            button.backgroundColor = action.backgroundColor
            button.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
            
            view.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.constrain(.width, toItem: view)
            button.constrain(.height, constant: 50)
            button.constrain(.leading, .trailing, .bottom, toItem: view)
            buttons.append(button)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    func buttonPress(sender: UIButton) {
        guard let actions = actions else { return }
        for action in actions {
            for button in buttons {
                if button.titleLabel?.text == action.title {
                    action.handler()
                }
            }
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertTransition().then {
            $0.presenting = false
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertTransition()
    }
}

