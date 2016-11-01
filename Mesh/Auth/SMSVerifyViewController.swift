//
//  SMSVerifyViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SMSVerifyViewController: UIViewController {

    let header = UILabel(translates: false).then {
        $0.text = "Enter your code"
        $0.textColor = #colorLiteral(red: 0.2666666667, green: 0.2666666667, blue: 0.2666666667, alpha: 1); $0.font = .gothamLight(ofSize: 30)
    }
    let text = UILabel(translates: false).then {
        $0.text = "A text message was sent to "
        $0.font = .gothamBook(ofSize: 18)
    }
    let code = SkyFloatingLabelTextField(translates: false).then {
        $0.keyboardType = .numberPad
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        
        view.addSubviews(header, text, code)
        
        header.constrain((.top, 40), (.centerX, 0), toItem: view)
        
        text.constrain(.centerX, toItem: view)
        text.constrain(.top, constant: 25, toItem: header, toAttribute: .bottom)
        text.constrain(.leading, toItem: view, toAttribute: .leadingMargin)
        text.constrain(.trailing, toItem: view, toAttribute: .trailingMargin)
        
        code.constrain(.centerX, toItem: view)
        code.constrain(.top, constant: 20, toItem: text, toAttribute: .bottom)
        code.constrain(.leading, toItem: view, toAttribute: .leadingMargin)
        code.constrain(.trailing, toItem: view, toAttribute: .trailingMargin)
    }
    
    func done() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        UIApplication.shared.delegate?.window??.rootViewController = vc
    }

}
