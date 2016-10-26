//
//  LaunchCardView.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class LaunchCardViewController: BaseCardViewController {
    
    let bottom = UIView(translates: false).then {
        $0.backgroundColor = .white
        $0.constrain(.height, toItem: $0, toAttribute: .width, multiplier: 200/615)
    }
    let top = UIImageView(translates: false).then {
        $0.image = #imageLiteral(resourceName: "discover")
        $0.contentMode = .scaleAspectFit
    }
    let header = UILabel().then {
        $0.text = "Network"
        $0.font = .gothamBook(ofSize: 20)
        $0.textColor = .darkGray
    }
    let text = UILabel().then {
        $0.text = "Connect and chat with people in your industry"
        $0.font = .gothamBook(ofSize: 14); $0.textColor = .lightGray
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.7254901961, green: 0.9019607843, blue: 1, alpha: 1)
        view.layer.shadowOpacity = 0.40
        view.layer.shadowRadius = 5
        view.translates = false
        view.constrain((.height, 305))
        
        view.addSubviews(top, bottom)
        top.constrain(.centerX, toItem: view)
        top.constrain(.bottom, constant: -30, toItem: bottom, toAttribute: .top)
        top.constrain((.top, 40), (.leading, 25), (.trailing, -25), toItem: view)
        
        bottom.constrain(.bottom, .leading, .trailing, toItem: view)
        
        let stack = UIStackView(header, text, axis: .vertical)
        stack.translates = false
        stack.alignment = .center
        bottom.addSubview(stack)
        stack.constrain(.centerX, .centerY, .leadingMargin, .trailingMargin, toItem: bottom)
        stack.constrain((.bottom, -10), toItem: bottom)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottom.round(corners: [.bottomLeft, .bottomRight])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bottom.round(corners: [.bottomLeft, .bottomRight])
    }
}
