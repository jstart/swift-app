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
    @IBOutlet weak var initials: UILabel!
    var buttonHandler : (() -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        name.text = nil
        title.text = nil
        button.isHidden = true
        button.isSelected = false
        button.layer.borderWidth = 1
        profile.image = nil
        company.image = nil
        buttonHandler = nil
        initials.isHidden = true
        initials.text = nil
        profile.backgroundColor = .clear
    }
    
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
    
    func showInitials(firstName: String, lastName: String) {
        profile.backgroundColor = .gray
        initials.isHidden = false
        let firstInitial = firstName.characters.first ?? Character(" ")
        let lastInitial = lastName.characters.first ?? Character(" ")
        initials.text = ([firstInitial, lastInitial] as NSArray).componentsJoined(by: "").replace("\"", with: "").uppercased()
    }
    
    func configure(_ user: UserResponse){
        name.text = user.fullName()
        title.text = user.fullTitle()
    }
    
    @IBAction func pressed(_ sender: AnyObject) {
        button.layer.borderWidth = 0
        button.isSelected = true
        buttonHandler?()
    }
}
