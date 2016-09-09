//
//  InboxTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class InboxTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {

    var searchController : UISearchController!
    var quickCell : UIView?
    var field : UITextField = UITextField(translates: false)
    let searchResults = InboxSearchTableViewController()
    var sortItem : UIBarButtonItem?
    var addItem : UIBarButtonItem?
    var todoMessages = [MessageResponse]()
    var recentSearches = (UserDefaults.standard["RecentConnectionSearches"] as? [String]) ?? [String]()
    
    var quickReplyAction = {}

    override func viewDidLoad() {
        super.viewDidLoad()
                
        searchController = UISearchController(searchResultsController: searchResults)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "Search for people and messages"
        searchController.searchBar.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        sortItem = UIBarButtonItem(#imageLiteral(resourceName: "sorting"), target: self, action: #selector(sort))
        addItem = UIBarButtonItem(#imageLiteral(resourceName: "addFriends"), target: self, action: #selector(add))
        navigationItem.rightBarButtonItems = [sortItem!, addItem!]
        tableView.registerNib(ConnectionTableViewCell.self, MessageTableViewCell.self, MessagePreviewTableViewCell.self)

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        searchResults.recentSearches = recentSearches
        
        searchResults.inbox = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        todoMessages = Array(UserResponse.messages?.filter({$0.sender != UserResponse.current?._id && $0.text != ""}).prefix(2) ?? [])
        refresh()
    }
    
    func refresh() {
        Client.execute(UpdatesRequest(last_update: Int(Date().timeIntervalSince1970)), completionHandler: { response in
            guard let json = response.result.value as? JSONDictionary else { return }
            guard let connections = json["connections"] as? JSONDictionary else { return }
            guard let connectionsInner = connections["connections"] as? JSONArray else { return }
            UserResponse.connections = connectionsInner.map({ return Connection(JSON: $0) }).filter({ return $0.user._id != UserResponse.current?._id }).sorted(by: { return $0.user.first_name! < $1.user.first_name! })
            
            guard let messages = json["messages"] as? JSONDictionary else { return }
            guard let messagesInner = messages["messages"] as? JSONArray else { return }
            UserResponse.messages = messagesInner.map({return MessageResponse(JSON: $0)}).sorted(by: { $0.ts > $1.ts})
            self.todoMessages = Array(UserResponse.messages?.filter({$0.sender != UserResponse.current?._id && $0.text != ""}).prefix(2) ?? [])
            self.tableView.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { navigationItem.setRightBarButtonItems(nil, animated: true) }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { navigationItem.rightBarButtonItems = [sortItem!, addItem!] }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        guard let text = searchBar.text else { return true }; guard text != "" else { return true }
        recentSearches.append(text)
        searchResults.recentSearches = recentSearches
        UserDefaults.standard.set(recentSearches, forKey: "RecentConnectionSearches")
        return true
    }
    
    open func updateSearchResults(for searchController: UISearchController) {
        let search = searchController.searchResultsController as! InboxSearchTableViewController
        search.view.isHidden = false
        search.showRecents = searchController.searchBar.text == ""
        search.filterBy(text: searchController.searchBar.text!)
        search.tableView.reloadData()
    }
    
    func sort() {
        //navigationItem.rightBarButtonItems?[0].image = #imageLiteral(resourceName: "sortConnectionsClose")
        let pop = UITableViewController()
        pop.preferredContentSize = CGSize(width: view.frame.size.width - 20, height: 210)
        pop.modalPresentationStyle = .popover
        pop.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?[0]
        pop.popoverPresentationController?.delegate = self
        present(pop)
    }
    
    func add() { navigationController?.push(ContactsTableViewController()) }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { return .none }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return todoMessages.count > 0 ? 2 : 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if todoMessages.count > 0 && section == 0 { return todoMessages.count }
        return section == 0 && todoMessages.count > 0 ? todoMessages.count : UserResponse.connections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Filler" : "Filler"
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UILabel().then {
            $0.text = section == 0 && todoMessages.count > 0 ? "    TO DO" : "    " + String(UserResponse.connections?.count ?? 0) + " CONNECTIONS"
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
            $0.font = .systemFont(ofSize: 12)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && todoMessages.count > 0 {
            guard let message = todoMessages[safe: indexPath.row] else { return UITableViewCell() }
            guard let connection = UserResponse.connections?.filter({ return $0.user._id == message.sender }).first else { return UITableViewCell() }

            if SwiftLinkPreview.extractURL(message.text ?? "") != nil {
                let cell = tableView.dequeue(MessagePreviewTableViewCell.self, indexPath: indexPath)
                cell.leftButtons = [MGSwipeButton(title: "  Skip  ", backgroundColor: .green, callback: { sender in
                    let currentIndex = tableView.indexPath(for: sender!)!
                    self.todoMessages.remove(at: currentIndex.row)
                    if self.todoMessages.count == 0 {
                        tableView.deleteSections([indexPath.section], with: .automatic)
                    }else {
                        tableView.deleteRows(at: [currentIndex], with: .automatic)
                    }
                    return true
                })]
                cell.configure(message, user: connection.user, read: connection.read)
                cell.pressedAction = ({
                    let article = ArticleViewController()
                    article.url = SwiftLinkPreview.extractURL(message.text ?? "")?.absoluteString
                    article.user = connection.user
                    self.navigationController?.push(article)
                })
                return cell
            }else {
                let cell = tableView.dequeue(MessageTableViewCell.self, indexPath: indexPath)
                
                cell.leftButtons = [MGSwipeButton(title: "  Skip  ", backgroundColor: .green, callback: { sender in
                    let currentIndex = tableView.indexPath(for: sender!)!
                    self.todoMessages.remove(at: currentIndex.row)
                    if self.todoMessages.count == 0 {
                        tableView.deleteSections([indexPath.section], with: .automatic)
                    }else {
                        tableView.deleteRows(at: [currentIndex], with: .automatic)
                    }
                    return false
                })]
                
                let title = connection.read ? "Mark Unread" : "Mark Read"
                cell.rightButtons = [MGSwipeButton(title: title, backgroundColor: Colors.brand, callback: { sender in
                    Client.execute(MarkReadRequest(read: !connection.read, id: connection.user._id), completionHandler: { _ in })
                    cell.add(read: !connection.read)
                    self.refresh()
                    return true
                }),
                 MGSwipeButton(title: "Mute", backgroundColor: .gray, callback: { sender in return true }),
                 MGSwipeButton(title: "Block", backgroundColor: .red, callback: { sender in
                    Client.execute(ConnectionDeleteRequest(connection_id: connection._id), completionHandler: { _ in })
                    UserResponse.connections?.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    return true
                 })]
                cell.configure(message, user: connection.user, read: connection.read)
                cell.pressedAction = ({ self.presentQuickReply(user: connection.user, message: message) })
                return cell
            }
        } else {
            let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath)
            guard let connection = UserResponse.connections?[safe: indexPath.row] else { return cell }
            cell.configure(connection.user)
            
            let title = connection.read ? "Mark Unread" : "Mark Read"
            cell.rightButtons = [MGSwipeButton(title: title, backgroundColor: Colors.brand, callback: { sender in
                Client.execute(MarkReadRequest(read: !connection.read, id: connection.user._id), completionHandler: { _ in })
                cell.add(read: !connection.read)
                self.refresh()
                return true
            }),
            MGSwipeButton(title: "Mute", backgroundColor: .gray, callback: { sender in return true }),
            MGSwipeButton(title: "Block", backgroundColor: .red, callback: { sender in
                Client.execute(ConnectionDeleteRequest(connection_id: connection._id), completionHandler: { _ in })
                UserResponse.connections?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                return true
            })]
            let message = UserResponse.messages?.filter({ return $0.recipient == connection.user._id || $0.sender == connection.user._id })[safe: 0]
            cell.add(message: message, read: connection.read)
            return cell
        }
    }
    
    func presentQuickReply(user: UserResponse, message: MessageResponse){
        quickCell = self.quickReplyView(user: user, message: message)
        let window = UIApplication.shared.delegate!.window!
        if (window?.subviews.contains(self.quickCell!))! { return }
        self.quickCell!.alpha = 0.0
        UIApplication.shared.delegate!.window!?.addSubview(self.quickCell!)
        UIView.animate(withDuration: 0.2, animations: {
            UIApplication.shared.delegate?.window??.windowLevel = UIWindowLevelStatusBar + 1
            self.quickCell!.alpha = 1.0
            self.quickCell!.constrain(.width, .height, .top, .leading, toItem: window)
            self.field.becomeFirstResponder()
        })
    }
    
    func quickReplyView(user: UserResponse, message: MessageResponse) -> UIView {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! MessageTableViewCell
        
        cell.contentView.translates = false
        cell.contentView.backgroundColor = .white
        cell.reply.isHidden = true
        cell.name.text = user.fullName()
        cell.profile.image = #imageLiteral(resourceName: "profile_sample")
        cell.company.image = #imageLiteral(resourceName: "tesla")
        cell.message.text = message.text ?? ""
        cell.message.numberOfLines = 2
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissQuickReply))
        blurView.addGestureRecognizer(tapGesture)
        blurView.translates = false
        
        blurView.addSubview(cell.contentView)
        cell.contentView.constrain(.width, .top, .leading, toItem: blurView)
        
        field.placeholder = "Send a message..."
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        spacer.backgroundColor = .white
        field.leftView = spacer;
        
        let right = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 15))
        right.addTarget(self, action: #selector(send), for: .touchUpInside)
        right.setTitleColor(.lightGray, for: .normal)
        right.setTitle("Send", for: .normal)
        field.rightView = right
        field.delegate = self
        
        field.rightViewMode = .always
        field.leftViewMode = .always
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1.0
        field.backgroundColor = .white
        blurView.addSubview(field)
        field.constrain(.height, constant: 50)
        field.constrain(.width, constant: 2, toItem: cell.contentView)
        field.constrain(.leading, constant: -1, toItem: cell.contentView)
        field.constrain(.top, toItem: cell.contentView, toAttribute: .bottom)

        quickReplyAction = {
            Client.execute(MessagesSendRequest(recipient: message.sender, text: self.field.text ?? ""), completionHandler: { response in
                self.dismissQuickReply()
            })
        }
        return blurView
    }
    
    func send() { quickReplyAction(); self.refresh() }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { send(); return true }
    
    func dismissQuickReply() {
        UIView.animate(withDuration: 0.2, animations: {
            UIApplication.shared.delegate?.window??.windowLevel = UIWindowLevelNormal
            self.quickCell!.alpha = 0.0
            self.field.resignFirstResponder()
        }, completion: { _ in
            self.quickCell!.removeFromSuperview()
            self.field.text = ""
        })
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var connection: Connection?
        if indexPath.section == 0 && todoMessages.count > 0 {
            guard let message = todoMessages[safe: indexPath.row] else { return }
            connection = UserResponse.connections?.filter({ return $0.user._id == message.sender || $0.user._id == message.recipient }).first
        } else {
            connection = UserResponse.connections?[safe: indexPath.row]
        }
        let conversationVC = MessagesViewController()
        conversationVC.recipient = connection ?? nil
        
        conversationVC.hidesBottomBarWhenPushed = true
        navigationController?.push(conversationVC)
    }

}
