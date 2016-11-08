//
//  ConnectionTableViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 8/22/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class ConnectionTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var company: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var initials: UILabel!
    
    var buttonHandler : (() -> Void)?
    let read = MGSwipeButton(title: "Mark Unread", backgroundColor: Colors.brand, callback: nil)!,
        mute = MGSwipeButton(title: "Mute", backgroundColor: .gray, callback: nil)!,
        block = MGSwipeButton(title: "Block", backgroundColor: .red, callback: nil)!
    
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
        
        name.font = .gothamBook(ofSize: name.font.pointSize)
        title.font = .gothamMedium(ofSize: title.font.pointSize)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profile.clipsToBounds = true
        profile.layer.cornerRadius = 5.0
        company.clipsToBounds = true
        company.layer.cornerRadius = 5.0
        
        name.textColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
        
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.brand.cgColor
        button.layer.cornerRadius = 5.0
        
        leftSwipeSettings.transition = .drag
        rightSwipeSettings.transition = .drag
        
        separatorInset = .zero
    }
    
    func showInitials(firstName: String, lastName: String) {
        profile.image = nil
        profile.backgroundColor = .gray
        initials.isHidden = false
        let firstInitial = firstName.characters.first ?? Character(" "), lastInitial = lastName.characters.first ?? Character(" ")
        initials.text = ([firstInitial, lastInitial] as NSArray).componentsJoined(by: "").replace("\"", with: "").uppercased()
    }

    func configure(_ user: UserResponse?) {
        name.text = user?.fullName()
        title.text = user?.fullTitle()
        if let url = user?.companies.first?.logo {
            company.af_setImage(withURL: URL(string: url)!)
        } else { company.image = nil }
        guard let url = user?.photos?.large else { showInitials(firstName: (user?.first_name) ?? "", lastName: (user?.last_name) ?? ""); return }
        profile.af_setImage(withURL: URL(string: url)!)
    }
    
    func configure(_ detail: UserDetail) {
        name.text = detail.firstText
        title.text = detail.secondText
        company.image = nil
        if detail is EventResponse {
            profile.contentMode = .scaleAspectFit
        }
        guard let imageURL = detail.logo else { profile.backgroundColor = .gray; return }
        profile.af_setImage(withURL: URL(string: imageURL)!)
    }
    
    func add(message: MessageResponse? = nil, read: Bool) {
        self.read.title = read ? "Mark Unread" : "Mark Read"
        
        if !read {
            name.font = .gothamBold(ofSize: name.font.pointSize)
            title.font = .gothamBold(ofSize: title.font.pointSize)
        } else {
            name.font = .gothamBook(ofSize: name.font.pointSize)
            title.font = .gothamBook(ofSize: title.font.pointSize)
        }
        if message?.text != nil { title.text = message?.text }
    }
    
    @IBAction func pressed(_ sender: AnyObject) {
        button.layer.borderWidth = 0
        button.isSelected = true
        button.setTitle(button.title(for: .selected), for: .normal)
        buttonHandler?()
    }
    
}
