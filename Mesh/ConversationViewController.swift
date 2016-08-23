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
        
        title = "Connection Name"
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "chatOverflow"), style: .plain, target: self, action: #selector(overflow)),
                                              UIBarButtonItem(image: #imageLiteral(resourceName: "chatMarkAsUnread"), style: .plain, target: self, action: #selector(toggleReadState))]
        
        addChildViewController(messagesVC)
        view.addSubview(messagesVC.view)
        messagesVC.view.constrain(.width, .height, .centerX, .centerY, toItem: view)
        messagesVC.view.translatesAutoresizingMaskIntoConstraints = false
    }

    func toggleReadState() {
        
    }
    
    func overflow() {
        
    }
}
