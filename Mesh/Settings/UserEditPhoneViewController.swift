//
//  UserEditPhoneViewController
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class UserEditPhoneViewController: UITableViewController {
    
    var formatter = PhoneNumberFormatter()
    let header = UILabel(translates: false).then {
        $0.text = "Change Your Phone Number"; $0.font = .gothamBold(ofSize: 20)
    }
    let text = UILabel(translates: false).then {
        $0.numberOfLines = 0
        $0.text = "This new phone number will replace the number that you're currently using in the app."
        $0.font = .gothamBook(ofSize: 16); $0.textColor = .gray
        $0.textAlignment = .center
    }
    let nextButton = UIButton(translates: false).then {
        $0.setBackgroundImage(.imageWithColor(Colors.brand), for: .normal)
        $0.setBackgroundImage(.imageWithColor(.lightGray), for: .disabled)
        $0.isEnabled = true
        $0.titleLabel?.font = .gothamBold(ofSize: 20); $0.title = "CONTINUE"; $0.titleColor = .white
        $0.layer.cornerRadius = 5; $0.clipsToBounds = true
        $0.constrain((.height, 70))
    }
    
    let phone = SkyFloatingLabelTextField.branded("Phone Number").then {
        $0.keyboardType = .phonePad
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Change Number"
        
        view.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.backgroundColor = .white
        
        phone.text = UserResponse.current?.phone_number
        
        phone.addTarget(self, action: #selector(format), for: .allEditingEvents)
        
        let inputView = UIView(translates: false)
        inputView.addSubview(nextButton)
        nextButton.constrain((.centerX, 0), (.bottom, -20), toItem: inputView)
        nextButton.constrain(.leading, relatedBy: .lessThanOrEqual, toItem: inputView, toAttribute: .leadingMargin)
        nextButton.constrain(.trailing, relatedBy: .lessThanOrEqual, toItem: inputView, toAttribute: .trailingMargin)
        
        phone.addTarget(self, action: #selector(fieldEdited), for: .allEditingEvents)
        phone.inputAccessoryView = inputView
        
        nextButton.addTarget(self, action: #selector(complete), for: .touchUpInside)
        
        let tableHeader = UIView(translates: false)
        tableHeader.addSubviews(header, text)
        header.constrain((.top, 20), (.centerX, 0), toItem: tableHeader)
        
        text.constrain(.top, toItem: header, toAttribute: .bottom)
        text.constrain((.leading, 20), (.trailing, -20), (.bottom, -25), (.centerX, 0), toItem: tableHeader)
        
        tableView.tableHeaderView = tableHeader
        tableHeader.constrain(.centerX, .width, .top, toItem: view)
        tableHeader.layoutIfNeeded()
        tableView.tableHeaderView = tableHeader
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let _ = phone.becomeFirstResponder()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
        cell.selectionStyle = .none
        
        var field : SkyFloatingLabelTextField? = nil
        switch indexPath.row {
        case 0: field = phone; cell.addSubview(phone); break
        default: break }
        field?.constrain((.height, -10), (.leading, 15), (.trailing, -15), toItem: cell)
        return cell
    }
    
    func format() { phone.text = formatter.format(phone.text!) }
    
    func fieldEdited() { nextButton.superview?.superview?.constraintFor(.height)?.constant = 90; nextButton.isEnabled = phone.text != ""}
    
    func complete() {
        navigationController?.pop()
        //navigationController?.push(SMSVerifyViewController())
    }

}
