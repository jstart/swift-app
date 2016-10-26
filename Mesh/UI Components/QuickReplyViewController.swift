//
//  QuickReplyViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/29/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import JSQMessagesViewController

enum QuickReplyType { case tweet, message }

class QuickReplyViewController: UIViewController, UIViewControllerTransitioningDelegate, UITextFieldDelegate {
    
    var cell : MessageTableViewCell?
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)).then { $0.translates = false }
    let field = UITextField(translates: false).then {
        $0.font = .gothamBook(ofSize: 15)
        $0.rightViewMode = .always
        $0.leftViewMode = .always
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 1.0
        $0.backgroundColor = .white
        $0.constrain(.height, relatedBy: .greaterThanOrEqual, constant: 50)
    }
    let sendButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 15)).then {
        $0.titleColor = Colors.brand
        $0.setTitleColor(.lightGray, for: .disabled)
        $0.titleLabel?.font = .gothamLight(ofSize: 17)
        $0.title = "Send"
        $0.isEnabled = false
    }
    let formatter = DateFormatter().then {
        //$0.dateFormat = "h:mm a"
        $0.locale = Locale.autoupdatingCurrent
        $0.dateStyle = .short
        $0.timeStyle = .short
        $0.doesRelativeDateFormatting = true
    }
    
    var user: UserResponse?, text: String?, date: Int?, type: QuickReplyType?
    var action : ((String?) -> Void)?
    
    convenience init(_ user: UserResponse?, text: String, date: Int, type: QuickReplyType = .message) {
        self.init(); self.user = user; self.text = text; self.date = date; self.type = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cell = (MainBundle.loadNibNamed("MessageTableViewCell", owner: self, options: [:])!.first as! MessageTableViewCell).then {
            $0.contentView.translates = false
            $0.contentView.backgroundColor = .white
            $0.reply.isHidden = true
            $0.message.numberOfLines = 2
            $0.company.image = type! == .tweet ? #imageLiteral(resourceName: "twtr-icn-logo") : nil
            $0.configure(text, user: user!, read: false)
            if date != 0 {
                $0.date.text = JSQMessagesTimestampFormatter.shared().timestamp(for: Date(timeIntervalSince1970: Double(date!/1000)))
            }
        }

        blurView.addSubview(cell!.contentView)
        cell!.contentView.constrain(.width, .top, .leading, toItem: blurView)
        
        field.placeholder = "Send a message..."
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        spacer.backgroundColor = .white
        field.leftView = spacer;
       
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        
        field.rightView = sendButton
        field.delegate = self
        field.addTarget(self, action: #selector(fieldChanged(sender:)), for: .allEditingEvents)

        blurView.addSubview(field)
        field.constrain((.width, 2), (.leading, -1), toItem: cell!.contentView)
        field.constrain(.top, toItem: cell!.contentView, toAttribute: .bottom)
        
        view.addSubview(blurView)
        
        blurView.constrain(.leading, .trailing, .top, .bottom, toItem: view)
        transitioningDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        field.becomeFirstResponder()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss(animated:)))
        blurView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.delegate?.window??.windowLevel = UIWindowLevelNormal
    }
    
    func fieldChanged(sender: UITextField) {
        sendButton.isEnabled = sender.text != ""
        SocketHandler.sendTyping(userID: user?._id ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" { send(); return true }
        return false
    }
    
    func send() { action?(field.text); dismiss() }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? { return QuickReplyTransition().then { $0.presenting = false } }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? { return QuickReplyTransition() }
    
}
