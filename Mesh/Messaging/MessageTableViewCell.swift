//
//  MessageTableViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 8/22/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class MessageTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var company: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var reply: UIButton!
    
    let skip = MGSwipeButton(title: "  Skip  ", backgroundColor: .green, callback: nil)!,
        read = MGSwipeButton(title: "Mark Unread", backgroundColor: Colors.brand, callback: nil)!,
        mute = MGSwipeButton(title: "Mute", backgroundColor: .gray, callback: nil)!,
        block = MGSwipeButton(title: "Block", backgroundColor: .red, callback: nil)!
    
    var pressedAction = {}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        name.text = nil
        message.text = nil
        
        name.font = .proxima(ofSize: name.font.pointSize)
        message.font = .proxima(ofSize: message.font.pointSize)
        
        profile.image = nil
        company.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profile.clipsToBounds = true
        profile.layer.cornerRadius = 5.0
        company.clipsToBounds = true
        company.layer.cornerRadius = 5.0

        reply.layer.borderColor = #colorLiteral(red: 0.1647058824, green: 0.7098039216, blue: 0.9960784314, alpha: 1).cgColor
        reply.layer.borderWidth = 1.5
        reply.layer.cornerRadius = 5.0

        name.textColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
        
        profile.backgroundColor = .gray
        company.image = #imageLiteral(resourceName: "tesla")
        
        leftExpansion.threshold = 1.5
        leftExpansion.fillOnTrigger = true
        leftExpansion.buttonIndex = 0

        leftSwipeSettings.transition = .drag
        rightSwipeSettings.transition = .drag
    }
    
    func configure(_ messageText: String?, user: UserResponse, read: Bool) {
        name.text = user.fullName()
        if !read {
            name.font = .boldProxima(ofSize: name.font.pointSize)
            message.font = .boldProxima(ofSize: message.font.pointSize)
        }
        profile.image = .imageWithColor(.gray)
//        company.image = .imageWithColor(.gray)
        message.text = messageText
        guard let large = user.photos?.large else { return }
        profile.af_setImage(withURL: URL(string: large)!)
    }
    
    func add(message: MessageResponse? = nil, read: Bool) {
        self.read.title = read ? "Mark Unread" : "Mark Read"

        if !read {
            name.font = .boldProxima(ofSize: name.font.pointSize)
            self.message.font = .boldProxima(ofSize: self.message.font.pointSize)
        } else {
            name.font = .proxima(ofSize: name.font.pointSize)
            self.message.font = .proxima(ofSize: self.message.font.pointSize)
        }
        if message?.text != nil { self.message.text = message?.text }
    }
    
    @IBAction func pressed(_ sender: AnyObject) { pressedAction() }
    
}
