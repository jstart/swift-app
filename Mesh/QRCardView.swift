//
//  QRCardView.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class QRCardView: CardView {
    
    var stackView : UIStackView?
    
    let qrImage = UIImageView(translates: false).then {
        $0.constrain(.width, .height, constant: 100)
        $0.backgroundColor = AlertAction.defaultBackground
    }
    
    let name = UILabel(translates: false).then {
        $0.textColor = .black
        $0.font = .boldSystemFont(ofSize: 22)
    }
    
    let pageControl = UIPageControl(translates: false).then {
        $0.currentPageIndicatorTintColor = Colors.brand
        $0.pageIndicatorTintColor = .lightGray
        $0.constrain((.height, 5), (.width, 100))
    }
    var tapAction = {}
    
    let title = QRCardView.detailLabel(""), email = QRCardView.detailLabel(""), phone = QRCardView.detailLabel("")

    convenience init(_ user: UserResponse, fields: [ProfileFields]) {
        self.init()
        addSubview(qrImage)
        qrImage.image = "http://tinderventures.com".qrImage(withSize: CGSize(width: 100, height: 100), foreground: Colors.brand, background: .white)
        qrImage.constrain(.leading, constant: 15, toItem: self)
        qrImage.constrain(.centerY, toItem: self)
        
        name.text = user.fullName()
        title.text = user.fullTitle()
        email.text = "email@test.com"
        phone.text = user.phone_number ?? ""
        
        viewsForFields(fields).forEach({ $0.isHidden = false })

        stackView = UIStackView(arrangedSubviews: [name, title, email, phone]).then {
            $0.axis = .vertical
            $0.distribution = .equalSpacing
            $0.alignment = .leading
            $0.spacing = 2
            $0.translates = false
        }
        
        addSubview(stackView!)

        stackView?.constrain(.leading, constant: 10, toItem: qrImage, toAttribute: .trailing)
        stackView?.constrain(.trailing, constant: 10, toItem: self)

        stackView?.constrain(.centerY, toItem: self)
        stackView?.constrain(.top, relatedBy: .greaterThanOrEqual, constant: 10, toItem: self)
        stackView?.constrain(.bottom, relatedBy: .lessThanOrEqual, constant: -10, toItem: self)
        
        addSubview(pageControl)

        pageControl.constrain(.centerX, toItem: self)
        pageControl.constrain(.bottom, constant: -10, toItem: self)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }
    
    func tapped(){ tapAction() }
    
    func setToken(_ token: String, animated: Bool = false) {
        let image = token.qrImage(withSize: CGSize(width: 100, height: 100), foreground: Colors.brand, background: .white)
        if !animated { qrImage.image = image } else {
            let rotation = CABasicAnimation(keyPath: "transform.rotation.y")
            rotation.duration = 0.5
            rotation.fromValue = 0
            rotation.toValue = 2 * CGFloat(M_PI)
            qrImage.layer.add(rotation, forKey: rotation.keyPath)
            
            let crossFade = CABasicAnimation(keyPath:"contents")
            crossFade.duration = 0.5
            crossFade.fromValue = qrImage.image!.cgImage
            crossFade.toValue = image!.cgImage
            qrImage.layer.add(crossFade, forKey: crossFade.keyPath)
            qrImage.image = image
        }
    }
    
    func updateFields(_ fields: [ProfileFields]) {
        stackView?.arrangedSubviews.forEach({ $0.isHidden = true })
        viewsForFields(fields).forEach({ $0.isHidden = false })
    }
    
    func viewsForFields(_ fields: [ProfileFields]) -> [UIView] {
        var views = [UIView]()
        for field in fields {
            switch field {
            case .name: views.append(name); break
            case .title: views.append(title); break
            case .email: views.append(email); break
            case .phone: views.append(phone); break
            }
        }
        return views
    }
    
    static func detailLabel(_ text: String) -> UILabel {
        return UILabel().then {
            $0.textColor = .lightGray
            $0.font = .systemFont(ofSize: 16)
            $0.text = text
            $0.isHidden = true
        }
    }

}
