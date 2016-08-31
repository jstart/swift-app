//
//  ConnectionTableViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 8/22/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class ConnectionTableViewCell: UITableViewCell {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var company: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var button: UIButton!
    var buttonHandler : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profile.clipsToBounds = true
        profile.layer.cornerRadius = 5.0
        company.clipsToBounds = true
        company.layer.cornerRadius = 5.0
        
        name.textColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
        
        button.layer.borderWidth = 1
        button.layer.borderColor = AlertAction.defaultBackground.cgColor
        button.layer.cornerRadius = 5.0
    }
    
    func configure(_ user: UserResponse){
        name.text = user.fullName()
        guard let company = user.companies?.first else {
            title.text = (user.title ?? "")
            return
        }
        title.text = (user.title ?? "") + " at " + company.id
    }
    
    @IBAction func pressed(_ sender: AnyObject) {
        button.layer.borderWidth = 0
        guard (buttonHandler != nil) else { return }
        buttonHandler!()
    }
}
