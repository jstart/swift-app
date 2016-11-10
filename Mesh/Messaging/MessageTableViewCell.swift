//
//  MessageTableViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 8/22/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MessageTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var reply: UIButton!
    @IBOutlet weak var roundedView: UIView!
    
    let skip = MGSwipeButton(title: "  Skip  ", backgroundColor: .clear, callback: nil)!.then { $0.titleColor = Colors.brand; $0.titleLabel?.font = .gothamBook(ofSize: 13) },
        read = MGSwipeButton(title: "Mark Unread", backgroundColor: Colors.brand, callback: nil)!,
        mute = MGSwipeButton(title: "Mute", backgroundColor: .gray, callback: nil)!,
        block = MGSwipeButton(title: "Block", backgroundColor: .red, callback: nil)!
    let formatter = DateFormatter().then {
        //$0.dateFormat = "h:mm a"
        $0.locale = Locale.autoupdatingCurrent
        $0.dateStyle = .short
        $0.timeStyle = .short
        $0.doesRelativeDateFormatting = true
    }
    var pressedAction = {}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        name.text = nil
        message.text = nil
        
        name.font = .gothamBook(ofSize: name.font.pointSize)
        message.font = .gothamBook(ofSize: message.font.pointSize)
        date.font = .gothamBook(ofSize: 11)

        profile.image = nil
        reply.backgroundColor = #colorLiteral(red: 0.168627451, green: 0.2901960784, blue: 0.462745098, alpha: 1)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profile.clipsToBounds = true
        profile.layer.cornerRadius = 5.0

        roundedView.layer.cornerRadius = 5.0
        roundedView.layer.shadowOffset = .zero
        roundedView.layer.shadowOpacity = 0.4
        roundedView.layer.shadowRadius = 2.5
        roundedView.layer.shadowColor = UIColor.black.cgColor
        reply.layer.borderColor = Colors.brand.cgColor
        reply.layer.borderWidth = 1.5
        reply.layer.cornerRadius = 2.5
        
        profile.backgroundColor = .gray
        
        leftExpansion.fillOnTrigger = true
        leftExpansion.buttonIndex = 0

        leftSwipeSettings.keepButtonsSwiped = false
        leftSwipeSettings.transition = .static
        rightSwipeSettings.transition = .drag
    }
    
    func configure(_ messageText: String?, user: UserResponse, read: Bool) {
        name.text = user.fullName()
        if !read {
            name.font = .gothamBold(ofSize: name.font.pointSize)
            message.font = .gothamBold(ofSize: message.font.pointSize)
        }
        profile.image = .imageWithColor(.gray)
        message.text = messageText
        guard let large = user.photos?.large else { return }
        profile.af_setImage(withURL: URL(string: large)!, imageTransition: .crossDissolve(0.2))
        date.font = .gothamBook(ofSize: 11)
    }
    
    func add(message: MessageResponse? = nil, read: Bool) {
        self.read.title = read ? "Mark Unread" : "Mark Read"

        if !read {
            name.font = .gothamBold(ofSize: name.font.pointSize)
            self.message.font = .gothamBold(ofSize: self.message.font.pointSize)
        } else {
            name.font = .gothamBook(ofSize: name.font.pointSize)
            self.message.font = .gothamBook(ofSize: self.message.font.pointSize)
        }
        if message?.text != nil { self.message.text = message?.text }
        date.text = JSQMessagesTimestampFormatter.shared().timestamp(for: Date(timeIntervalSince1970: Double(message!.ts/1000)))
    }
    
    @IBAction func pressed(_ sender: AnyObject) { reply.backgroundColor = #colorLiteral(red: 0.168627451, green: 0.2901960784, blue: 0.462745098, alpha: 1); pressedAction() }
    
    @IBAction func drag(_ sender: Any) { reply.backgroundColor = #colorLiteral(red: 0.168627451, green: 0.2901960784, blue: 0.462745098, alpha: 1) }
    @IBAction func highlight(_ sender: Any) { reply.backgroundColor = #colorLiteral(red: 0.05098039216, green: 0.09411764706, blue: 0.1176470588, alpha: 1) }
    @IBAction func dragexit(_ sender: Any) { reply.backgroundColor = #colorLiteral(red: 0.168627451, green: 0.2901960784, blue: 0.462745098, alpha: 1) }
    @IBAction func unhighlight(_ sender: Any) { reply.backgroundColor = #colorLiteral(red: 0.168627451, green: 0.2901960784, blue: 0.462745098, alpha: 1) }
}
