//
//  ArticleViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/23/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import WebKit

class ArticleViewController: UIViewController {

    let web = WKWebView(translates: false)
    var url: String? = "https://hackernoon.com/instagram-just-slapped-snapchat-in-the-face-and-kicked-its-dog-5e3135abef06"
    var user: UserResponse?
    var message: MessageResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reed Hastings shared this with you"
        view.addSubview(web)

        web.constrain(.width, .height, .centerX, .centerY, toItem: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        web.load(URLRequest(url: URL(string: url!)!))
    }

}
