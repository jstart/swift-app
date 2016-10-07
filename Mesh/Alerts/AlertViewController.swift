//
//  AlertViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/29/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

struct AlertAction {
    static let defaultBackground = #colorLiteral(red: 0.4196078431, green: 0.768627451, blue: 0.9647058824, alpha: 1)
    let title : String, backgroundColor, titleColor : UIColor
    var handler : (() -> Void)
}

class AlertViewController: UIViewController, UIViewControllerTransitioningDelegate {

    let imageView = UIImageView(translates: false).then {
        $0.contentMode = .scaleAspectFit
        $0.constrain(.height, .width, constant: 100)
    }
    let titleLabel = UILabel(translates: false).then {
        $0.textAlignment = .center
        $0.font = .boldProxima(ofSize: 20); $0.textColor = .black
    }
    let textLabel = UILabel(translates: false).then {
        $0.contentMode = .top
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .proxima(ofSize: 16); $0.textColor = .lightGray
    }
    var actions = [AlertAction]()
    var buttons = [UIButton]()
    
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
        view.translates = false
        view.constrain(.width, .height, constant: 325)
        
        view.addSubviews(imageView, titleLabel, textLabel)
        imageView.constrain((.top, 40), (.centerX, 0), toItem: view)
        
        titleLabel.constrain(.width, .centerX, toItem:view)
        titleLabel.constrain(.top, constant: 20, toItem: imageView, toAttribute: .bottom)
        
        textLabel.constrain(.centerX, toItem:view)
        textLabel.constrain(.width, constant: -40, toItem:view)
        textLabel.constrain(.top, toItem: titleLabel, toAttribute: .bottom)
        //textLabel.constrain(.bottom, constant: -50, toItem: view)

        for (index, action) in actions.enumerated() {
            let button = UIButton(translates: false).then {
                $0.setTitle(action.title, for: .normal)
                $0.setTitleColor(action.titleColor, for: .normal)
                $0.titleLabel?.font = .boldProxima(ofSize: 20)
                $0.setBackgroundImage(.imageWithColor(action.backgroundColor), for: .normal)
                $0.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
                $0.constrain(.height, constant: 50)
            }
            view.addSubview(button)
            if actions.count == 1 {
                button.constrain(.width, toItem: view)
                button.constrain(.leading, .trailing, .bottom, toItem: view)
            } else {
                if index == 0 {
                    button.constrain(.leading, .bottom, toItem: view)
                }else {
                    button.constrain(.leading, toItem: buttons[0], toAttribute: .trailing)
                    button.constrain(.width, toItem: buttons[0])
                    button.constrain(.trailing, .bottom, toItem: view)
                }
            }
            
            buttons.append(button)
        }
    }

    func buttonPress(sender: UIButton) { for action in actions {  if sender.titleLabel?.text == action.title { action.handler() } } }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? { return AlertTransition().then { $0.presenting = false } }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? { return AlertTransition() }

}
