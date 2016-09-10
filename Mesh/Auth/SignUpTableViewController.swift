//
//  SignUpTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SignUpTableViewController: UITableViewController, UITextFieldDelegate {

    var phoneField : UITextField?
    var passwordField : UITextField?
    var formatter = PhoneNumberFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign Up"
        tableView.registerClass(UITableViewCell.self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(signUp))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        phoneField?.becomeFirstResponder()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Phone Number" : "Password"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
        let field = UITextField(translates: false).then {
            $0.delegate = self
            $0.autocapitalizationType = .none
        }
        
        cell.addSubview(field)
        field.constrain(.leadingMargin, .trailing, .height, .centerY, toItem: cell)
        if indexPath.section == 0 {
            phoneField = field
            phoneField?.placeholder = "(555) 123-4567"
            phoneField?.keyboardType = .phonePad
            phoneField?.autocapitalizationType = .none
            phoneField?.autocorrectionType = .no
        } else {
            passwordField = field
            passwordField?.isSecureTextEntry = true
        }
        return cell
    }
    
    func signUp() {
        Client.execute(AuthRequest(phone_number: phoneField!.text!.onlyNumbers(), password: passwordField!.text!, password_verify: passwordField!.text!), completionHandler: { response in
            if response.result.value != nil {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
                UIApplication.shared.delegate!.window??.rootViewController = vc
                let tab = UIApplication.shared.delegate!.window??.rootViewController as! UITabBarController
                tab.tabBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            } else {
                let alert = UIAlertController(title: "Error", message: response.result.error?.localizedDescription ?? "Unknown Error", preferredStyle: .alert)
                alert.addAction(UIAlertAction("Ok", style: .cancel))
                self.present(alert)
            }
        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool { if textField == passwordField { signUp() }; return true }
    
    func format() { phoneField?.text = formatter.format(phoneField?.text ?? "") }
    
    override var canBecomeFirstResponder: Bool { return true }
    override var keyCommands: [UIKeyCommand]? {
        return [UIKeyCommand(input: "l", modifierFlags: [.command, .alternate], action: #selector(fill), discoverabilityTitle: "Convenience")]
    }
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) { if motion == .motionShake { fill(UIKeyCommand()) } }
    
    func fill(_ command: UIKeyCommand) {
        phoneField?.text = "3103479814"
        passwordField?.text = "password"
        signUp()
    }
}
