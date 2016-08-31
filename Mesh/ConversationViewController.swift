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
    var recipient : UserResponse?
    
    let label = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.constrain(.height, constant: 44)
    }
    
    let imageView = UIImageView().then {
        $0.layer.cornerRadius = 5.0
        $0.clipsToBounds = true
        $0.backgroundColor = .gray
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.constrain(.width, .height, constant: 30)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "chatOverflow"), style: .plain, target: self, action: #selector(overflow)),
                                              UIBarButtonItem(image: #imageLiteral(resourceName: "chatMarkAsUnread"), style: .plain, target: self, action: #selector(toggleReadState))]
        addChildViewController(messagesVC)
        view.addSubview(messagesVC.view)
        messagesVC.view.constrain(.width, .height, .centerX, .centerY, toItem: view)
        messagesVC.view.translatesAutoresizingMaskIntoConstraints = false
        messagesVC.recipient = recipient
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        label.text = recipient?.fullName() ?? ""
        
        let container = UIStackView(arrangedSubviews: [imageView, label]).then{
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .fillProportionally
            $0.spacing = 10
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.constrain(.height, constant: 44)
        }
        navigationItem.titleView = container
        
        guard let url = recipient?.photos?.large else { return }
        imageView.af_setImage(withURL: URL(string: url)!)
    }

    func toggleReadState() {
        
    }
    
    func overflow() {
        
    }
}
