//
//  MessagesViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import TwitterKit

class MessagesViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    var recipient : UserResponse?
    var meshMessages : [MessageResponse]?
    let label = UILabel(translates: false).then { $0.constrain(.height, constant: 44) }
    
    let imageView = UIImageView(translates: false).then {
        $0.layer.cornerRadius = 5.0
        $0.clipsToBounds = true
        $0.backgroundColor = .gray
        $0.constrain(.width, .height, constant: 30)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "chatOverflow"), style: .plain, target: self, action: #selector(overflow)),
                                              UIBarButtonItem(image: #imageLiteral(resourceName: "chatMarkAsUnread"), style: .plain, target: self, action: #selector(toggleReadState))]
        
        let imageButton = UIButton(translates: false)
        imageButton.addTarget(self, action: #selector(image), for: .touchUpInside)
        imageButton.setImage(#imageLiteral(resourceName: "chatUploadPhoto"), for: .normal)
        inputToolbar.contentView?.leftBarButtonItem = imageButton
        inputToolbar.contentView?.textView?.placeHolder = "Send a message..."
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(editMessage(_:)))
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(deleteMessage(_:)))
        inputToolbar.preferredDefaultHeight = 200
//        TWTRAPIClient().loadTweet(withID: "631879971628183552") { (tweet, error) in
//            guard let unwrappedTweet = tweet else { print("Tweet load error:\(error!.localizedDescription)"); return }
//            let media = TwitterMessageMedia(TWTRTweetView(tweet: unwrappedTweet))
//            let message = JSQMessage(senderId: self.senderId(), displayName: self.senderDisplayName(), media: media)
//            self.messages.append(message)
//        }
    }

    override func senderId() -> String { return UserResponse.current?._id ?? "-1" }
    override func senderDisplayName() -> String { return UserResponse.current?.first_name ?? "Name" }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        meshMessages = UserResponse.messages?.filter({return $0.recipient == recipient?._id && $0.text != ""}).sorted(by: { $0.ts < $1.ts})
        meshMessages?.forEach({
            let message = JSQMessage(senderId: self.senderId(), senderDisplayName: self.senderDisplayName(), date: Date(timeIntervalSince1970: TimeInterval($0.ts/1000)), text: $0.text!)
            self.messages.append(message)
            self.collectionView?.reloadData()
        })
        showTypingIndicator = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView?.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 44, right: 0)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        label.text = recipient?.fullName() ?? ""
        
        let container = UIStackView(arrangedSubviews: [imageView, label]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .fillProportionally
            $0.spacing = 10
            $0.translates = false
            $0.constrain(.height, constant: 44)
        }
        navigationItem.titleView = container

        guard let url = recipient?.photos?.large else { return }
        imageView.af_setImage(withURL: URL(string: url)!)
    }
    
    func toggleReadState() { }
    
    func overflow() { }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        Client.execute(MessagesSendRequest(recipient: recipient?._id ?? "", text: text), completionHandler: { response in
            self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
            self.finishSendingMessage(animated: true)
        })
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        if messages[indexPath.row].senderId == senderId() {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: .gray)
        }
        return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: .blue)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellBottomLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.row]
        return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellBottomLabelAt indexPath: IndexPath) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(editMessage(_:)) || action == #selector(deleteMessage(_:)){ return true }
        return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(editMessage(_:)){ editMessage(indexPath) }
        if action == #selector(deleteMessage(_:)){ deleteMessage(indexPath) }
        super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? JSQMessagesCollectionViewCell)?.textView?.delegate = self
    }
    
    override func didReceiveMenuWillShow(_ notification: Notification) {
        let menu = notification.object as! UIMenuController
        menu.menuItems = [UIMenuItem(title: "Edit", action: #selector(editMessage(_:))), UIMenuItem(title: "Delete", action: #selector(deleteMessage(_:)))]
        super.didReceiveMenuWillShow(notification)
    }
    
    func editMessage(_ indexPath: IndexPath) {
        //guard let meshMessage = meshMessages?[indexPath.row] else { return }
        /*Client().execute(MessagesEditRequest(_id: meshMessage._id), completionHandler: { response in
         let message = messages[indexPath.row]
         self.collectionView.reloadData()
        })*/
    }
    
    func deleteMessage(_ indexPath: IndexPath) {
        guard let meshMessage = meshMessages?[indexPath.row] else { return }
        Client.execute(MessagesDeleteRequest(id: meshMessage._id), completionHandler: { response in
            self.messages.remove(at: indexPath.row)
            self.collectionView?.reloadData()
        })
    }
    
    override func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
//        if URL.scheme == "http" || URL.scheme == "https" {
//            let articleVC = ArticleViewController()
//            articleVC.url = URL.absoluteString
//            navigationController?.push(articleVC)
//            return false
//        }
//        return true
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {  }
    
    func image() { }
}
