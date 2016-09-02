//
//  MessageTableViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 8/22/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class MessageTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var company: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var reply: UIButton!
    
    var pressedAction : (() -> Void)? = nil
    
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
    }
    
    func configure(_ aMessage: MessageResponse, user: UserResponse) {
        name.text = user.fullName()
        company.image = #imageLiteral(resourceName: "tesla")
        message.text = aMessage.text ?? ""
        guard let small = user.photos?.small else {
            profile.image = nil
            return
        }
        profile.af_setImage(withURL: URL(string: small)!)
    }
    
    @IBAction func pressed(_ sender: AnyObject) {
        pressedAction?()
    }
}
