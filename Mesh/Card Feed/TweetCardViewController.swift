//
//  TweetCardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import TwitterCore
import TwitterKit
import SafariServices

class TweetCardViewController : BaseCardViewController {
        
    let profile = UIImageView(translates: false).then {
        $0.constrain(.width, .height, constant: 40)
        $0.image = #imageLiteral(resourceName: "profile_sample")
        $0.layer.cornerRadius = 5.0
        $0.clipsToBounds = true
    }
    let name = UILabel(translates: false).then {
        $0.textColor = .darkGray
        $0.font = .boldProxima(ofSize: 18)
        $0.text = "John Doe"
    }
    let subtitle = UILabel(translates: false).then {
        $0.textColor = .lightGray
        $0.font = .proxima(ofSize: 15)
        $0.text = "Popular in your industry"
    }
    let sourceIcon = UIImageView(translates: false).then {
        $0.constrain((.width, 25), (.height, 20))
        $0.contentMode = .scaleAspectFit
    }
    let media = UIImageView(translates: false).then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1; $0.layer.borderColor = UIColor.clear.cgColor
        $0.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)
    }
    let text = UILabel(translates: false).then {
        $0.numberOfLines = 0
        $0.text = "Instagram may have copied Snapchat, but it’s still a pretty cool feature. Love how they push it in discovery 🙌 t.co/gwcwjunXl4"
        $0.textColor = .black
        $0.font = .proxima(ofSize: 18)
    }
    let articleTitle = UILabel(translates: false).then {
        $0.textColor = .darkGray
        $0.font = .boldProxima(ofSize: 18)
        $0.text = "Now on Slack - Click, done."
        $0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
    }
    let articleURL = UILabel(translates: false).then {
        $0.textColor = .lightGray
        $0.font = .proxima(ofSize: 15)
        $0.text = "slackhq.com/get-more-work…"
        $0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
    }
    let retweet = UIButton(translates: false).then {
        $0.setImage(#imageLiteral(resourceName: "Retweet"), for: .normal)
        $0.title = "34"; $0.titleColor = .lightGray
        $0.titleLabel?.font = .proxima(ofSize: 18)
        $0.constrain((.height, 40))
        $0.contentEdgeInsets = UIEdgeInsetsMake(10, 0, 10, 0)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    let like = UIButton(translates: false).then {
        $0.setImage(#imageLiteral(resourceName: "Heart"), for: .normal)
        $0.title = "34"; $0.titleColor = .lightGray
        $0.titleLabel?.font = .proxima(ofSize: 18)
        $0.titleEdgeInsets = UIEdgeInsetsMake(-10, 10, -10, 0)
        $0.contentEdgeInsets = UIEdgeInsetsMake(10, 0, 10, 0)
        $0.constrain((.height, 40  ), (.width, 63))
        $0.imageView?.contentMode = .scaleAspectFit
    }
    let reply = UIButton(translates: false).then {
        $0.setImage(#imageLiteral(resourceName: "Reply"), for: .normal)
        $0.constrain((.height, 40))
        $0.contentEdgeInsets = UIEdgeInsetsMake(10, 15, 10, 20)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(profile, sourceIcon, media, text)

        profile.constrain((.leading, 10), (.top, 10), toItem: view)
        sourceIcon.constrain((.trailing, -15), toItem: view)
        sourceIcon.constrain(.centerY, toItem: profile)
        sourceIcon.image = rec!.cardType() == .tweet ? #imageLiteral(resourceName: "twtr-icn-logo") : #imageLiteral(resourceName: "medium")

        let titleStack = UIStackView(name, subtitle, axis: .vertical)
        titleStack.translates = false
        view.addSubview(titleStack)

        titleStack.constrain((.height, 0), (.top, 0), toItem: profile)
        titleStack.constrain(.leading, constant: 12, toItem: profile, toAttribute: .trailing)
        titleStack.constrain(.trailing, constant: -12, toItem: sourceIcon, toAttribute: .leading)
        
        if rec!.cardType() == .tweet {
            name.text = rec?.tweet?.name
            
            text.text = rec?.tweet?.text
            text.constrain(.top, constant: 10, toItem: profile, toAttribute: .bottom)
            text.constrain((.leading, 15), (.trailing, -15), toItem: view)
            text.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            media.constrain(.top, constant: 12, toItem: text, toAttribute: .bottom)
        }else {
            text.removeFromSuperview()
            media.constrain(.top, constant: 12, toItem: titleStack, toAttribute: .bottom)
        }
        
        media.constrain(.leading, .trailing, toItem: view)
        
        retweet.addTarget(self, action: #selector(retweetAction), for: .touchUpInside)
        like.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
        reply.addTarget(self, action: #selector(replyAction), for: .touchUpInside)
        
        let actionStack = UIStackView(retweet, like, reply, spacing: 35)
        actionStack.alignment = .center
        actionStack.distribution = .fillProportionally
        actionStack.translates = false
        
        if rec!.cardType() == .tweet {
            view.addSubview(actionStack)
            actionStack.constrain((.height, 50))
            actionStack.constrain((.leading, 15), (.bottom, 0), toItem: view)
        }
        
        if rec!.contentType() == .article {
            let articleStack = UIStackView(articleTitle, articleURL, axis: .vertical, spacing: 5)
            articleStack.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            articleStack.translates = false
            view.addSubview(articleStack)
            articleStack.constrain((.leading, 15), (.trailing, -15), toItem: view)
            if rec!.cardType() == .tweet {
                articleStack.constrain(.bottom, toItem: actionStack, toAttribute: .top)
            } else {
                articleStack.constrain(.bottom, constant: -10, toItem: view)
            }
            media.constrain(.bottom, constant: -10, toItem: articleStack, toAttribute: .top)
        } else if rec!.contentType() == .photo {
            media.constrain(.bottom, constant: 0, toItem: actionStack, toAttribute: .top)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        media.af_setImage(withURL: URL(string: "https://scontent.xx.fbcdn.net/t31.0-8/12829144_10207668383179007_4083742861292722789_o.jpg")!)
    }
    
    func retweetAction() {
        retweet.isEnabled = false
        Snackbar(title: "Retweeting...", buttonTitle: "UNDO", buttonHandler: { [weak self] in
            self?.retweet.isEnabled = true
            return true
            }, dismissed: { [weak self] in
                // https://dev.twitter.com/rest/reference/post/statuses/retweet/%3Aid
                let client = TWTRAPIClient.withCurrentUser()
                let request = client.urlRequest(withMethod: "POST", url: "https://api.twitter.com/1.1/statuses/retweet/" + "778697854617473024" + ".json", parameters: [:], error: nil)
                client.sendTwitterRequest(request, completion: { [weak self] response, data, error in
                    self?.delegate?.passCard(.left)
                    Snackbar(title: "Retweeted").presentIn(self?.view.superview)
                })
        }).presentIn(view.superview)
    }
    
    func likeAction() {
        like.isEnabled = false
        // https://dev.twitter.com/rest/reference/post/favorites/create

        let client = TWTRAPIClient.withCurrentUser()
        let request = client.urlRequest(withMethod: "POST", url: "https://api.twitter.com/1.1/favorites/create.json", parameters: ["id": "778697854617473024"], error: nil)
        client.sendTwitterRequest(request, completion: { [weak self] response, data, error in
            self?.delegate?.passCard(.left)
        })
    }
    
    func replyAction() {
        let quick = QuickReplyViewController(nil, text: rec!.tweet!.text, type: .tweet)
        quick.modalPresentationStyle = .overFullScreen
        quick.action = { [weak self] string in
            Snackbar(title: "Replying To Tweet...", buttonTitle: "UNDO", buttonHandler: {
                return true
                }, dismissed: { [weak self] in
                    let client = TWTRAPIClient.withCurrentUser()
                    // https://dev.twitter.com/rest/reference/post/statuses/update
                    let request = client.urlRequest(withMethod: "POST", url: "https://api.twitter.com/1.1/statuses/update.json", parameters: ["status": "@jasarien " + string!, "in_reply_to_status_id": "778697854617473024"], error: nil)
                    client.sendTwitterRequest(request, completion: { [weak self] response, data, error in
                        self?.delegate?.passCard(.left) })
                    self?.delegate?.passCard(.left)
                    Snackbar(title: "Replied To Tweet").presentIn(self?.view.superview)
            }).presentIn(self?.view.superview)
        }
        present(quick)
    }
    
    override func tap(_ sender: UITapGestureRecognizer) { let safari = SFSafariViewController(url: URL(string: "https://twitter.com/@iAmChrisTruman")!); safari.modalPresentationStyle = .popover; present(safari) }
    
}
