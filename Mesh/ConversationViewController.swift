//
//  ConversationViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ConversationViewController: UIViewController {

    let messagesVC = MessagesViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "LoginName"
        
        addChildViewController(messagesVC)
        view.addSubview(messagesVC.view)
        messagesVC.view.constrain(.width, .height, .centerX, .centerY, toItem: view)
        messagesVC.view.translatesAutoresizingMaskIntoConstraints = false
    }

}
