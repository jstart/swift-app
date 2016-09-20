//
//  PersonCardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import TwitterKit

class TweetPersonCardViewController : BaseCardViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TWTRAPIClient().loadTweet(withID: "631879971628183552") { (tweet, error) in
            guard let unwrappedTweet = tweet else {
                print("Tweet load error:\(error!.localizedDescription)")
                return
            }
            let tweetView = TWTRTweetView(tweet: unwrappedTweet)
            tweetView.presenterViewController = self
            self.view.addSubview(tweetView)
            tweetView.translates = false
            tweetView.constrain(.width, .centerX, .centerY, toItem: self.view)
            self.view.bringSubview(toFront: self.overlayView)
        }
    }
    
    override func tap(_ sender: UITapGestureRecognizer) { }
    
}
