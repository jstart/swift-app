//
//  MessagePreviewTableViewCell.swift
//  Mesh
//
//  Created by Christopher Truman on 8/22/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class MessagePreviewTableViewCell : MGSwipeTableCell {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var company: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var viewArticle: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var articleHolder: UIView!
    
    var pressedAction : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profile.clipsToBounds = true
        profile.layer.cornerRadius = 5.0
        company.clipsToBounds = true
        company.layer.cornerRadius = 5.0
        name.textColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
    }
    
    func configure(_ aMessage: MessageResponse, user: UserResponse) {
        name.text = user.fullName()
        company.image = #imageLiteral(resourceName: "tesla")
        message.text = aMessage.text ?? ""
        let slp = SwiftLinkPreview()
        activity.startAnimating()
        slp.preview(
            "http://hackernoon.com/instagram-just-slapped-snapchat-in-the-face-and-kicked-its-dog-5e3135abef06",
            onSuccess: { result in
                self.activity.stopAnimating()
                self.activity.isHidden = true
                self.articleTitle.text = result["title"] as? String
                self.articleImage.af_setImage(withURL: URL(string: result["image"] as! String)!)
                self.articleTitle.isHidden = false
                self.articleImage.isHidden = false
                self.viewArticle.isHidden = false
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.pressed(_:)))
                self.articleHolder.addGestureRecognizer(tap)
                print("\(result)")
            }, onError: { error in
                print("\(error)")
                self.activity.stopAnimating()
                self.activity.isHidden = true
                //TODO: Handle preview failures, HTTPS ATS
                /*UIView.animate(withDuration: 0.2, animations: {
                    self.articleHolder.constrain(.height, constant: 0)
                    self.layoutIfNeeded()
                })*/
               }
        )
        
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
