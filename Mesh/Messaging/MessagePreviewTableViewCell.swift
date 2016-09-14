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
    
    let skip = MGSwipeButton(title: "  Skip  ", backgroundColor: .green, callback: nil)
    
    var pressedAction : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profile.clipsToBounds = true
        profile.layer.cornerRadius = 5.0
        company.clipsToBounds = true
        company.layer.cornerRadius = 5.0
        name.textColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        name.text = nil
        message.text = nil
        
        name.font = .proxima(ofSize: name.font.pointSize)
        message.font = .proxima(ofSize: message.font.pointSize)
    }
    
    func configure(_ aMessage: MessageResponse, user: UserResponse, read: Bool) {
        name.text = user.fullName()
        company.image = #imageLiteral(resourceName: "tesla")
        message.text = aMessage.text ?? ""
        if !read {
            name.font = .boldProxima(ofSize: name.font.pointSize)
            message.font = .boldProxima(ofSize: message.font.pointSize)
        }
        activity.startAnimating()
        preview(url: message.text!)
        
        guard let small = user.photos?.small else { profile.image = nil; return }
        profile.af_setImage(withURL: URL(string: small)!)
    }
    
    func preview(url: String) {
        let slp = SwiftLinkPreview()
        slp.preview(url,
            onSuccess: { result in
                self.activity.stopAnimating()
                self.activity.isHidden = true
                self.articleTitle.text = result["title"] as? String
                self.articleTitle.isHidden = false
                self.articleImage.isHidden = false
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.pressed(_:)))
                self.articleHolder.addGestureRecognizer(tap)
                
                guard var imageURL = result["image"] as? String else { self.articleImage.backgroundColor = .darkGray; return }
                guard imageURL != "" else { self.articleImage.backgroundColor = .darkGray; return }
                imageURL = imageURL.replace("http://", with: "https://")
                self.articleImage.af_setImage(withURL: URL(string: imageURL)!, completion: { response in
                    if response.result.error != nil {
                        self.articleImage.backgroundColor = .darkGray
                    }
                })
            }, onError: { error in
                if error?._code == -1022 {
                    self.preview(url: error?.userInfo["NSErrorFailingURLStringKey"] as! String)
                    return
                }
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    self.activity.isHidden = true
                }
                
                //TODO: Handle preview failures, HTTPS ATS
                /*UIView.animate(withDuration: 0.2, animations: {
                 self.articleHolder.constrain(.height, constant: 0)
                 self.layoutIfNeeded()
                 })*/
        })
    }
    
    @IBAction func pressed(_ sender: AnyObject) { pressedAction?() }
}
