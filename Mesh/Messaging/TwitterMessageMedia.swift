//
//  TwitterMessageMedia.swift
//  Mesh
//
//  Created by Christopher Truman on 8/26/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import TwitterKit

class TwitterMessageMedia: NSObject, JSQMessageMediaData {
    var tweet : TWTRTweetView
    
    init(_ aTweet: TWTRTweetView) {
        tweet = aTweet
        super.init()
    }
    
    open func mediaView() -> UIView? {
        return tweet
    }

    open func mediaViewDisplaySize() -> CGSize {
        return tweet.frame.size
    }

    open func mediaPlaceholderView() -> UIView {
        return TWTRTweetView()
    }

    open func mediaHash() -> UInt {
        return UInt(tweet.tweet.tweetID) ?? 1
    }
    
}
