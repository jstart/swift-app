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
    var recipient : ConnectionResponse?
    var meshMessages : [MessageResponse]?
    
    var typingTimer : Timer?
    var senderImage : UIImage?
    var shouldReload = true
    
    let label = UILabel(translates: false).then {
        $0.constrain(.height, constant: 44)
        $0.font = .proxima(ofSize: 18)
    }
    let imageView = UIImageView(translates: false).then {
        $0.layer.cornerRadius = 5.0
        $0.clipsToBounds = true
        $0.backgroundColor = .gray
        $0.contentMode = .scaleAspectFit
        $0.constrain(.width, .height, constant: 30)
    }
    let container = UIView(translates: false).then { $0.constrain(.height, constant: 44) }
    
    let outgoingImage = JSQMessagesBubbleImage(messageBubble: .imageWithColor(Colors.brand), highlightedImage: .imageWithColor(#colorLiteral(red: 0.9450980392, green: 0.9411764706, blue: 0.9411764706, alpha: 1)))
    let incomingImage = JSQMessagesBubbleImage(messageBubble: .imageWithColor(#colorLiteral(red: 0.9450980392, green: 0.9411764706, blue: 0.9411764706, alpha: 1)), highlightedImage: .imageWithColor(Colors.brand))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [UIBarButtonItem(#imageLiteral(resourceName: "overflow"), target: self, action: #selector(overflow)),
                                              UIBarButtonItem(#imageLiteral(resourceName: "chatMarkAsUnread"), target: self, action: #selector(toggleReadState))]
        
        let imageButton = UIButton(translates: false)
        imageButton.addTarget(self, action: #selector(image), for: .touchUpInside)
        imageButton.setImage(#imageLiteral(resourceName: "chatUploadPhoto"), for: .normal)
        inputToolbar.contentView?.leftBarButtonItem = imageButton
        inputToolbar.contentView?.textView?.placeHolder = "Send a message..."
//        JSQMessagesCollectionViewCell.registerMenuAction(#selector(editMessage(_:)))
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(deleteMessage(_:)))
        inputToolbar.preferredDefaultHeight = 200
        
        collectionView?.collectionViewLayout.messageBubbleFont = .proxima(ofSize: 17)
        
        DefaultNotification.addObserver(self, selector: #selector(userIsTyping(notification:)), name: .typing, object: nil)
        DefaultNotification.addObserver(self, selector: #selector(receivedMessage(notification:)), name: .message, object: nil)

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
        //title = recipient?.user?.fullName()
        if shouldReload {
            self.refresh()
            Client.execute(MarkReadRequest(read: true, id: recipient?.user?._id ?? "")) { _ in
                self.recipient?.write { $0.read = true }
            }
        }
        
        label.text = recipient?.user?.fullName()

        container.addSubviews(imageView, label)
        
        imageView.constrain(.leading, .centerY, toItem: container)
        label.constrain(.leading, constant: 5, toItem: imageView, toAttribute: .trailing)
        label.constrain(.trailing, .centerY, toItem: container)
        
        guard let url = recipient?.user?.photos?.large else { return }
        imageView.af_setImage(withURL: URL(string: url)!)
        container.layoutIfNeeded()
        navigationController?.navigationBar.addSubview(container)
        container.constrain(.centerY, .centerX, toItem: navigationController?.navigationBar)
        container.constrain((.width, 150))
        container.alpha = 0.0; container.fadeIn(duration: 0.2, delay: 0.2)
        
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedUser)))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        container.fadeOut(duration: 0.1)
        typingTimer?.invalidate()
    }
    
    func userIsTyping(notification: Notification) {
        guard let sender = notification.object as? JSONDictionary else { return }
        guard (sender["sender"] as? String) == recipient?.user?._id else { return }
        showTypingIndicator = true
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(userStoppedTyping), userInfo: nil, repeats: false)
    }
    
    func userStoppedTyping() {
        showTypingIndicator = false
    }
    
    func receivedMessage(notification: Notification) {
        self.refresh()
    }
    
    func refresh() {
        Client.execute(UpdatesRequest.latest(), complete: { response in
            UpdatesRequest.append(response) {
                if self.meshMessages?.count != UserResponse.messages.filter({return ($0.recipient == self.recipient?.user?._id || $0.sender == self.recipient?.user?._id) && $0.text != ""}).sorted(by: { $0.ts < $1.ts}).count {
                    self.messages.removeAll()

                    self.meshMessages = UserResponse.messages.filter({return ($0.recipient == self.recipient?.user?._id || $0.sender == self.recipient?.user?._id) && $0.text != ""}).sorted(by: { $0.ts < $1.ts})
                    self.meshMessages?.forEach({
                        let message = JSQMessage(senderId: $0.sender, senderDisplayName: self.senderDisplayName(), date: Date(timeIntervalSince1970: TimeInterval($0.ts/1000)), text: $0.text!)
                        self.messages.append(message)
                    })
                    self.collectionView?.reloadData()
                    if self.messages.count > 0 {
                        self.collectionView?.scrollToItem(at: IndexPath(item: max(0, self.messages.count - 1), section: 0), at: .bottom, animated: false)
                    }
                }
            }
        })
    }
    
    func toggleReadState() {
        guard let recipient = recipient else { return }
        Client.execute(MarkReadRequest(read: !recipient.read, id: (recipient.user?._id)!), complete: { _ in
            self.recipient?.write { $0.read = !$0.read }
        })
        
        Snackbar(title: "Marked " + (!recipient.read ? "Read" : "Unread")).presentIn(inputToolbar)
    }
    
    func overflow() {
        guard let recipient = recipient else { return }

        let title = recipient.read ? "Mark Unread" : "Mark Read"
        let readState = UIAlertAction(title) { _ in self.inputToolbar.fadeIn(); self.toggleReadState() }
        let mute = UIAlertAction("Mute") { _ in self.inputToolbar.fadeIn() }
        let block = UIAlertAction("Block") { _ in self.inputToolbar.fadeIn(); self.block() }
        let cancel = UIAlertAction.cancel() { _ in self.inputToolbar.fadeIn() }
        let sheet = UIAlertController.sheet()
        sheet.addActions(readState, mute, block, cancel)
        present(sheet)
        inputToolbar.alpha = 0.0
    }
    
    func block() {
        guard let recipient = recipient else { return }
        Client.execute(ConnectionDeleteRequest(connection_id: recipient._id))
        recipient.delete()
        navigationController?.pop()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return messages.count }
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData { return messages[indexPath.item] }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        Client.execute(MessagesSendRequest(recipient: recipient?.user?._id ?? "", text: text), complete: { response in
            self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
            self.finishSendingMessage(animated: true)
        })
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        return isOutgoingMessage(messages[indexPath.row]) ? outgoingImage : incomingImage
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.messageBubbleContainerView?.layer.cornerRadius = 5.0
        cell.messageBubbleContainerView?.clipsToBounds = true
        cell.textView?.textColor = isOutgoingMessage(messages[indexPath.row]) ? .white : .black
        cell.cellBottomLabel?.font = .proxima(ofSize: 10)
        cell.avatarImageView?.layer.cornerRadius = 5
        cell.avatarImageView?.clipsToBounds = true
        
        return cell
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellBottomLabelAt indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.row == 0 { return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: messages[indexPath.row].date) }
        
        let message = messages[indexPath.row]
        guard let secondMessage = messages[safe: indexPath.row - 1] else { return nil }
        guard messages[safe: indexPath.row + 1] != nil else { return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: messages[indexPath.row].date) }

        if message.date.timeIntervalSince(secondMessage.date) < 60 * 5 { return nil }
        return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: messages[indexPath.row].date)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellBottomLabelAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return kJSQMessagesCollectionViewCellLabelHeightDefault }
        
        let message = messages[indexPath.row]
        guard let secondMessage = messages[safe: indexPath.row - 1] else { return 0 }
        guard messages[safe: indexPath.row + 1] != nil else { return kJSQMessagesCollectionViewCellLabelHeightDefault }
        if message.date.timeIntervalSince(secondMessage.date) < 60 * 5 { return 0 }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? { return isOutgoingMessage(messages[indexPath.row]) ? nil : JSQMessagesAvatarImage(placeholder: .imageWithColor(.gray, width: 10, height: 10)) }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(editMessage(_:)) || action == #selector(deleteMessage(_:)){ return true }
        return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
//        if action == #selector(editMessage(_:)){ editMessage(indexPath) }
        if action == #selector(deleteMessage(_:)){ deleteMessage(indexPath) }
        super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
    }
    
    override func didReceiveMenuWillShow(_ notification: Notification) {
        let menu = notification.object as! UIMenuController
        //UIMenuItem(title: "Edit", action: #selector(editMessage(_:))),
        menu.menuItems = [UIMenuItem(title: "Delete", action: #selector(deleteMessage(_:)))]
        super.didReceiveMenuWillShow(notification)
    }
    
    func editMessage(_ indexPath: IndexPath) {
        //guard let meshMessage = meshMessages?[indexPath.row] else { return }
        /*Client().execute(MessagesEditRequest(_id: meshMessage._id), complete: { response in
         let message = messages[indexPath.row]
         self.collectionView.reloadData()
        })*/
    }
    
    func deleteMessage(_ indexPath: IndexPath) {
        guard let meshMessage = meshMessages?[indexPath.row] else { return }
        Client.execute(MessagesDeleteRequest(id: meshMessage._id), complete: { response in
            meshMessage.delete()
            self.messages.remove(at: indexPath.row)
            self.collectionView?.reloadData()
        })
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == inputToolbar.contentView?.textView {
            SocketHandler.sendTyping(userID: UserResponse.current!._id)
        }
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView == inputToolbar.contentView?.textView {
            SocketHandler.sendTyping(userID: UserResponse.current!._id)
        }
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
    
    func tappedUser() {
        let cardVC = PersonCardViewController(); cardVC.modalPresentationStyle = .overFullScreen
        let rec = RecommendationResponse(); rec.user = recipient?.user
        cardVC.rec = rec
        present(cardVC)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) { }
    
    func image() { }
    
}
