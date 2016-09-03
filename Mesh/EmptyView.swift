//
//  Emptyswift
//  Mesh
//
//  Created by Christopher Truman on 8/29/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EmptyView: UIView {

    var imageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.constrain(.height, .width, constant: 100)
    }
    var titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textColor = .black
    }
    var textLabel = UILabel().then {
        $0.contentMode = .top
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .lightGray
    }
    var actions : [AlertAction]?
    var buttons : [UIButton] = []
    
    convenience init(_ newActions : [AlertAction], image: UIImage = UIImage()) {
        self.init()
        actions = newActions
        imageView.image = image
        configure()
    }
    
    func configure() {
        backgroundColor = .white
        
        addSubview(imageView)
        imageView.constrain(.centerX, toItem: self)
        imageView.constrain(.top, constant: 40, toItem: self)
        
        addSubview(titleLabel)
        titleLabel.constrain(.width, .centerX, toItem:self)
        titleLabel.constrain(.top, constant: 20, toItem: imageView, toAttribute: .bottom)
        
        addSubview(textLabel)
        textLabel.constrain(.centerX, toItem:self)
        textLabel.constrain(.width, constant: -40, toItem:self)
        textLabel.constrain(.top, toItem: titleLabel, toAttribute: .bottom)

        guard let actions = actions else { return }
        for action in actions {
            let button = UIButton().then {
                $0.layer.cornerRadius = 5
                $0.setTitle(action.title, for: .normal)
                $0.titleLabel?.font = .boldSystemFont(ofSize:14)
                $0.setTitleColor(action.titleColor, for: .normal)
                $0.backgroundColor = action.backgroundColor
                $0.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
            }
            
            addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.constrain(.top, constant: 20, toItem: textLabel, toAttribute: .bottom)
            button.constrain(.width, constant: 150)
            button.constrain(.height, constant: 35)
            button.constrain(.centerX, toItem: self)
            buttons.append(button)
        }
    }

    func buttonPress(sender: UIButton) {
        guard let actions = actions else { return }
        for action in actions {
            for button in buttons {
                if button.titleLabel?.text == action.title {
                    action.handler()
                }
            }
        }
    }
    
}

