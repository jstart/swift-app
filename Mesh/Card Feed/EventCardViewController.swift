//
//  EventCardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import SafariServices

class EventCardViewController : BaseCardViewController {

    let name = UILabel().then {
        $0.textColor = .darkGray; $0.font = .boldProxima(ofSize: 18)
        $0.text = "John Doe"
    }
    let subtitle = UILabel().then {
        $0.textColor = .lightGray; $0.font = .proxima(ofSize: 15)
        $0.text = "Popular in your industry"
    }
    let media = UIImageView(translates: false).then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1; $0.layer.borderColor = UIColor.clear.cgColor
        $0.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)
    }
    let text = UILabel(translates: false).then {
        $0.textColor = .black; $0.font = .proxima(ofSize: 18)
        $0.numberOfLines = 0
        $0.text = ""
    }
    let articleTitle = UILabel(translates: false).then {
        $0.textColor = .darkGray; $0.font = .boldProxima(ofSize: 18)
        $0.text = ""
        $0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
    }
    let articleURL = UILabel(translates: false).then {
        $0.textColor = .lightGray; $0.font = .proxima(ofSize: 15)
        $0.text = ""
        $0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(media)
        media.constrain(.top, .leading, .trailing, toItem: view)
        
        let titleStack = UIStackView(name, subtitle, axis: .vertical)
        titleStack.translates = false
        view.addSubview(titleStack)
        
        titleStack.constrain((.height, 40))
        titleStack.constrain(.top, constant: 10, toItem: media, toAttribute: .bottom)
        titleStack.constrain((.bottom, -10), (.leading, 12), (.trailing, -12), toItem: view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        media.round(corners: [.topLeft, .topRight])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        media.af_setImage(withURL: URL(string: "https://scontent.xx.fbcdn.net/t31.0-8/12829144_10207668383179007_4083742861292722789_o.jpg")!)
    }
    
    override func tap(_ sender: UITapGestureRecognizer) { let safari = SFSafariViewController(url: URL(string: "https://eventbrite.com")!); safari.modalPresentationStyle = .popover; present(safari) }
    
}
