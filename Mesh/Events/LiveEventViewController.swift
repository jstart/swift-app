//
//  LiveEventViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 10/3/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class LiveEventViewController: UIViewController {

    var pager : ViewPager?
    var event: EventResponse?
    let messageView = MessagesViewController()
    let formatter = DateFormatter().then {
        $0.dateFormat = "MMMM dd, yyyy - h a"
        $0.locale = Locale.autoupdatingCurrent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = event?.name
        view.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
        
        let logo = UIImageView(image: .imageWithColor(.gray, width: 85, height: 85)).then { $0.layer.cornerRadius = 5; $0.clipsToBounds = true; $0.contentMode = .scaleAspectFill }
        logo.constrain((.width, 85), (.height, 85))
        
        let header = UIView(translates: false).then { $0.backgroundColor = .white
            let name = UILabel().then { $0.textColor = .darkGray; $0.font = .gothamBold(ofSize: 20); $0.text = event?.name }
            let time = Double(event!.start_time)!
            let subtitle = UILabel().then { $0.textColor = .lightGray; $0.font = .gothamBook(ofSize: 12); $0.text = formatter.string(from: Date(timeIntervalSince1970: time)) }
            let titleStack = UIStackView(name, subtitle, axis: .vertical, spacing: 5).then { $0.distribution = .fillProportionally; $0.alignment = UIStackViewAlignment.leading }
            let stack = UIStackView(logo, titleStack, spacing: 10).then { $0.distribution = .fillProportionally }
            $0.addSubview(stack)
            
            stack.translates = false
            stack.constrain((.leading, 10), (.trailing, -10), (.centerY, 0), toItem: $0)
            $0.constrain((.height, 120))
        }
        
        view.addSubview(header)
        header.constrain(.leading, .trailing, .top, toItem: view)
        
        let barView = UIView(translates: false).then { $0.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1); $0.constrain(.height, constant: 1) }
        
        view.addSubview(barView)
        barView.constrain(.top, toItem: header, toAttribute: .bottom)
        barView.constrain(.leading, .trailing, toItem: view)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "overflow"), target: self, action: #selector(overflow))
        
        messageView.shouldReload = false
        let message = JSQMessage(senderId: "1", senderDisplayName: "Event Creator", date: Date(timeIntervalSince1970: Date().timeIntervalSince1970), text: "Welcome to the start of LA Hacks 2016! Stay tuned for exciting news.")
        messageView.messages.append(message)
        messageView.collectionView?.reloadData()

        messageView.willMove(toParentViewController: self)
        view.addSubview(messageView.view)
        messageView.view.translates = false
        messageView.view.constrain(.leading, .trailing, .bottom, toItem: view)
        messageView.view.layoutIfNeeded()
        messageView.view.constrain(.top, constant: 0, toItem: barView, toAttribute: .bottom)
        addChildViewController(messageView)

        view.sendSubview(toBack: messageView.view)
        //TODO: if not admin
//        messageView.inputToolbar.isHidden = false
        
        if let logoURL = event?.logo { logo.af_setImage(withURL: URL(string: logoURL)!) { _ in
            self.messageView.senderImage = logo.image
            self.messageView.collectionView?.reloadData()
        }}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO: if admin
        let textView = (messageView.collectionView?.visibleCells.first! as! JSQMessagesCollectionViewCell).textView!
        textView.inputAccessoryView = messageView.inputAccessoryView
        textView.becomeFirstResponder()
    }

    func overflow() {
        
    }
    
}
