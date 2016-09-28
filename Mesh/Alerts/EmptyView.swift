//
//  Emptyswift
//  Mesh
//
//  Created by Christopher Truman on 8/29/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EmptyView: UIView {

    var imageView = UIImageView(translates: false).then {
        $0.constrain(.height, .width, constant: 100)
    }
    var titleLabel = UILabel(translates: false).then {
        $0.textAlignment = .center
        $0.font = .boldProxima(ofSize: 20); $0.textColor = .black
    }
    var textLabel = UILabel(translates: false).then {
        $0.contentMode = .top
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .proxima(ofSize: 16); $0.textColor = .lightGray
    }
    var actions = [AlertAction]()
    var buttons : [UIButton] = []
    
    convenience init(_ newActions : [AlertAction], image: UIImage = UIImage()) {
        self.init()
        actions = newActions
        imageView.image = image
        backgroundColor = .white
        configure()
    }
    
    func configure() {
        addSubviews(imageView, titleLabel, textLabel)
        
        imageView.constrain(.centerX, toItem: self)
        imageView.constrain((.top, 40), toItem: self)
        
        titleLabel.constrain(.width, .centerX, toItem:self)
        titleLabel.constrain(.top, constant: 20, toItem: imageView, toAttribute: .bottom)
        
        textLabel.constrain(.centerX, toItem:self)
        textLabel.constrain((.width, -40), toItem:self)
        textLabel.constrain(.top, toItem: titleLabel, toAttribute: .bottom)

        for action in actions {
            let button = UIButton(translates: false).then {
                $0.layer.cornerRadius = 5
                $0.setTitle(action.title, for: .normal)
                $0.titleLabel?.font = .boldProxima(ofSize:14)
                $0.setTitleColor(action.titleColor, for: .normal)
                $0.backgroundColor = action.backgroundColor
                $0.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
            }
            
            addSubview(button)
            button.constrain(.top, constant: 20, toItem: textLabel, toAttribute: .bottom)
            button.constrain((.width, 150), (.height, 35))
            button.constrain(.centerX, toItem: self)
            buttons.append(button)
        }
    }

    func buttonPress(sender: UIButton) {
        for action in actions {
            guard sender.titleLabel?.text == action.title else { return }
            action.handler()
        }
    }
    
}
