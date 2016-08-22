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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        icon.layer.cornerRadius = 5.0
        
        button.layer.borderColor = #colorLiteral(red: 0.1647058824, green: 0.7098039216, blue: 0.9960784314, alpha: 1).cgColor
        button.layer.borderWidth = 1.5
        button.layer.cornerRadius = 5.0
    }
    
    func configure(detail:UserDetail) {
        button.isHidden = !detail.hasButton
        year.isHidden = !detail.hasDate
    }
    
    @IBAction func pressed(_ sender: AnyObject) {
        
    }
    
}
