//
//  LoginTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class LoginTableViewController: UITableViewController, UITextFieldDelegate {

    var phoneField, passwordField : UITextField?,
        formatter = PhoneNumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        tableView.registerClass(UITableViewCell.self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(login))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated); navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated); phoneField?.becomeFirstResponder()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return section == 0 ? "Phone Number" : "Password" }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
        let field = UITextField(translates: false).then { $0.delegate = self }
        cell.addSubview(field)
        field.constrain(.leadingMargin, .trailing, .height, .centerY, toItem: cell)
        if indexPath.section == 0 {
            phoneField = field
            phoneField?.placeholder = "(555) 123-4567"
            phoneField?.keyboardType = .phonePad
            phoneField?.autocapitalizationType = .none
            phoneField?.autocorrectionType = .no
            phoneField?.addTarget(self, action: #selector(format), for: .allEditingEvents)
        } else {
            passwordField = field
            passwordField?.isSecureTextEntry = true
            UITextField.connectFields(fields: [phoneField!, passwordField!])
        }
        return cell
    }
    
    func login() {
        Client.execute(LoginRequest(phone_number: "+1" + phoneField!.text!.onlyNumbers(), password: passwordField!.text!), complete: { response in
            if response.result.value != nil {
                LaunchData.fetchLaunchData()
                UIApplication.shared.delegate!.window??.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
                Keychain.deleteLogin()
                let _ = Keychain.addLogin(phone: self.phoneField!.text!, password: self.passwordField!.text!)
            } else {
                let alert = UIAlertController.alert(title: "Error", message: response.result.error?.localizedDescription ?? "Unknown Error")
                alert.addAction(UIAlertAction.ok())
                self.present(alert)
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { if textField == passwordField { login() }; return true }
    
    func format() { phoneField?.text = formatter.format(phoneField?.text ?? "") }
    
    override var canBecomeFirstResponder: Bool { return true }
    override var keyCommands: [UIKeyCommand]? { return [UIKeyCommand(input: "l", modifierFlags: [.command, .alternate], action: #selector(fill), discoverabilityTitle: "Convenience")] }
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) { if motion == .motionShake { fill(UIKeyCommand()) } }
    func fill(_ command: UIKeyCommand) {
        phoneField?.text = "3103479814"; passwordField?.text = "password"
        login()
    }

}
