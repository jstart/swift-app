//
//  UserDetailTableViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 8/21/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class UserDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var top: UILabel!
    @IBOutlet weak var bottom: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var delete: UIButton!
    
    var deleteHandler = {}, buttonHandler = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        icon.layer.cornerRadius = 5.0
        icon.clipsToBounds = true
        
        button.layer.borderColor = #colorLiteral(red: 0.1647058824, green: 0.7098039216, blue: 0.9960784314, alpha: 1).cgColor
        button.layer.borderWidth = 1.5
        button.layer.cornerRadius = 5.0
        icon.constrain(.width, toItem: icon, toAttribute: .height)
        
        icon.layer.borderWidth = 1
        icon.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        icon.layer.cornerRadius = 5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        icon.image = nil
        top.text = nil
        bottom.text = nil
        year.text = nil
        button.isHidden = true
        year.isHidden = true
        delete.isHidden = true
    }
    
    func configure(_ detail: UserDetail) {        
        button.isHidden = !detail.hasButton
        if !detail.hasButton {
            button.isHidden = true
            button.widthConstraint?.constant = 0
            delete.widthConstraint?.constant = 0
            delete.isHidden = true
        }
        year.isHidden = !detail.hasDate
        
        top.text = detail.firstText
        bottom.text = detail.secondText
        year.text = detail.thirdText
        if let logo = detail.logo {
            if detail.category == .connections { icon.contentMode = .scaleAspectFill }
            icon.af_setImage(withURL: URL(string: logo)!, imageTransition: .crossDissolve(0.2))
        }
    }
    
    @IBAction func pressed(_ sender: AnyObject) { buttonHandler() }
    @IBAction func deletePressed(_ sender: AnyObject) { deleteHandler() }
}
