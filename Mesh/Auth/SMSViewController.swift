//
//  SMSViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SMSViewController: UIViewController {
    
    var formatter = PhoneNumberFormatter()

    let phone = UITextField(translates: false).then {
        $0.placeholder = "(555) 123-4567"
        $0.keyboardType = .phonePad
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
    }
    
    let password = UITextField(translates: false).then {
        $0.isSecureTextEntry = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        phone.addTarget(self, action: #selector(format), for: .allEditingEvents)
    }
    
    func format() { phone.text = formatter.format(phone.text!) }

}
