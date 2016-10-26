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
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        button.isHidden = true
        year.isHidden = true
        delete.isHidden = true
    }
    
    func configure(_ detail: UserDetail) {        
        button.isHidden = !detail.hasButton
        if !detail.hasButton {
            button.widthConstraint.constant = 0
        }
        year.isHidden = !detail.hasDate
        
        top.text = detail.firstText
        bottom.text = detail.secondText
        year.text = detail.thirdText
        if let logo = detail.logo {
            icon.af_setImage(withURL: URL(string: logo)!)
        }
    }
    
    @IBAction func pressed(_ sender: AnyObject) { buttonHandler() }
    @IBAction func deletePressed(_ sender: AnyObject) { deleteHandler() }
}
