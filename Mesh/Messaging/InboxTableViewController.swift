//
//  InboxTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class InboxTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {

    var searchController : UISearchController!
    let searchResults = InboxSearchTableViewController()
    var sortItem : UIBarButtonItem?
    var addItem : UIBarButtonItem?
    var todoMessages = [MessageResponse]()
    var recentSearches = (StandardDefaults["RecentConnectionSearches"] as? [String]) ?? [String]()
    
    var coreMessages = [Message]()
    var coreConnections = [Connection]()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        searchController = UISearchController(searchResultsController: searchResults)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "Search for people"
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
        let valid = UserResponse.messages.filter({$0.sender != UserResponse.current?._id && $0.text != ""})
        guard let first = valid.first else { refresh(); return }
        todoMessages = [first]
        guard let second = valid.filter({$0.sender != first.sender && $0.text != ""}).first else { refresh(); return }
        todoMessages.append(second)
        self.tableView.reloadData()
        
        refresh()
    }
    
    func refresh() {
        Client.execute(UpdatesRequest.latest(), complete: { response in
            //TODO: updates won't reflect read/unread state unless we fetch a fresh copy of everything
//            UserResponse.connections = []
//            UserResponse.messages = []
            CoreData.backgroundContext.perform({
//                self.coreMessages = CoreData.fetch(Message.self) as! [Message]
                self.coreConnections = CoreData.fetch(Connection.self) as! [Connection]
                DispatchQueue.main.async { self.tableView.reloadData() }
            })

            UpdatesRequest.append(response) {
                CoreData.backgroundContext.perform({
                    guard let json = response.result.value as? JSONDictionary else { return }
                    guard let messages = (json["messages"] as? JSONDictionary)?["messages"] as? JSONArray else { return }
                    messages.forEach({ let _ = Message(JSON: $0)})
                    CoreData.saveBackgroundContext()
                })
                
                let valid = UserResponse.messages.filter({$0.sender != UserResponse.current?._id && $0.text != ""})
                guard let first = valid.first else { self.todoMessages = []; return }
                self.todoMessages = [first]
                guard let second = valid.filter({$0.sender != first.sender && $0.text != ""}).first else { self.tableView.reloadData(); return }
                self.todoMessages.append(second)
                self.tableView.reloadData()

//                CoreData.backgroundContext.perform({
//                    guard let json = response.result.value as? JSONDictionary else { return }
//                    guard let messages = (json["messages"] as? JSONDictionary)?["messages"] as? JSONArray else { return }
//                    _ = messages.map({return Message(JSON: $0)})
//                    CoreData.saveBackgroundContext()
//                    _ = CoreData.fetch(Message.self) as! [Message]
//                })
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchController.searchBar.resignFirstResponder(); searchController.isActive = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { navigationItem.setRightBarButtonItems(nil, animated: true) }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { self.navigationItem.setRightBarButtonItems([self.sortItem!, self.addItem!], animated: true) }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        guard let text = searchBar.text else { return true }; guard text != "" else { return true }
        recentSearches.append(text)
        searchResults.recentSearches = recentSearches
        StandardDefaults.set(recentSearches, forKey: "RecentConnectionSearches")
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
        return
        //TODO: Sorting
        //navigationItem.rightBarButtonItems?[0].image = #imageLiteral(resourceName: "sortConnectionsClose")
//        let pop = UITableViewController()
//        pop.preferredContentSize = CGSize(width: view.frame.size.width - 20, height: 210)
//        pop.modalPresentationStyle = .popover
//        pop.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?[0]
//        pop.popoverPresentationController?.delegate = self
//        present(pop)
    }
    
    func add() { navigationController?.push(ContactsTableViewController()) }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { return .none }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return todoMessages.count > 0 ? 2 : 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if todoMessages.count > 0 && section == 0 { return todoMessages.count }
        return section == 0 && todoMessages.count > 0 ? todoMessages.count : coreConnections.count//UserResponse.connections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Filler" : "Filler"
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UILabel().then {
            $0.text = section == 0 && todoMessages.count > 0 ? "    TO DO" : "    " + String(coreConnections.count ) + " CONNECTIONS"
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
            $0.font = .proxima(ofSize: 12)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && todoMessages.count > 0 {
            guard let message = todoMessages[safe: indexPath.row] else { return UITableViewCell() }
            guard let connection = coreConnections.filter({ return $0.user.id == message.sender }).first else { return UITableViewCell() }

//            if SwiftLinkPreview.extractURL(message.text ?? "") != nil {
//                let cell = tableView.dequeue(MessagePreviewTableViewCell.self, indexPath: indexPath)
//                cell.skip?.callback = { sender in
//                    let currentIndex = tableView.indexPath(for: sender!)!
//                    self.todoMessages.remove(at: currentIndex.row)
//                    if self.todoMessages.count == 0 {
//                        tableView.deleteSections([indexPath.section], with: .automatic)
//                    }else {
//                        tableView.deleteRows(at: [currentIndex], with: .automatic)
//                    }
//                    return true
//                }
//                cell.leftButtons = [cell.skip]
//                cell.configure(message, user: connection.user, read: connection.read)
//                cell.pressedAction = ({
//                    let article = ArticleViewController()
//                    article.url = SwiftLinkPreview.extractURL(message.text ?? "")?.absoluteString
//                    article.user = connection.user
//                    self.navigationController?.push(article)
//                })
//                return cell
//            }else {
            let cell = tableView.dequeue(MessageTableViewCell.self, indexPath: indexPath)
            cell.skip.callback = { sender in
                let currentIndex = tableView.indexPath(for: sender!)!
                self.todoMessages.remove(at: currentIndex.row)
                if self.todoMessages.count == 0 {
                    tableView.deleteSections([indexPath.section], with: .automatic)
                }else {
                    tableView.deleteRows(at: [currentIndex], with: .automatic)
                }
                return false
            }
            cell.leftButtons = [cell.skip]
            
            cell.read.callback = { _ in
                cell.add(read: !connection.read)
                Client.execute(MarkReadRequest(read: !connection.read, id: connection.user.id), complete: { _ in
                    connection.read = !connection.read
                    CoreData.saveBackgroundContext()
                    self.tableView.reloadData()
                })
                return true
            }
            cell.mute.callback = { sender in return true }
            cell.block.callback = { sender in
                Client.execute(ConnectionDeleteRequest(connection_id: connection.id))
                UserResponse.connections.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                return true
            }
            cell.rightButtons = [cell.read, cell.mute, cell.block]
            cell.configure(message, user: connection.user, read: connection.read)
            cell.pressedAction = ({ self.presentQuickReply(user: connection.user, message: message) })
            
            cell.add(message: message, read: connection.read)
            return cell
        } else {
            let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath)
            guard let connection = coreConnections[safe: indexPath.row] else { return cell }
            cell.configure(connection.user)
            
            let title = connection.read ? "Mark Unread" : "Mark Read"
            cell.read.titleLabel?.text = title
            cell.read.callback = { _ in
                cell.add(read: !connection.read)
                Client.execute(MarkReadRequest(read: !connection.read, id: connection.user.id), complete: { _ in
                    connection.read = !connection.read
                    CoreData.saveBackgroundContext()
                    self.tableView.reloadData()
                })
                return true
            }
            cell.mute.callback = { sender in return true }
            cell.block.callback = { sender in
                Client.execute(ConnectionDeleteRequest(connection_id: connection.id))
                UserResponse.connections.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                return true
            }
            cell.rightButtons = [cell.read, cell.mute, cell.block]
            
            let message = UserResponse.messages.filter({ return $0.recipient == connection.user.id || $0.sender == connection.user.id })[safe: 0]
            cell.add(message: message, read: connection.read)
            return cell
        }
    }
    
    func presentQuickReply(user: User, message: MessageResponse){
        let quickReply = QuickReplyViewController(user, text: message.text!)
        quickReply.modalPresentationStyle = .overFullScreen
        quickReply.action = { text in Client.execute(MessagesSendRequest(recipient: message.sender, text: text!), complete: { response in self.refresh() }) }
        present(quickReply)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var connection: ConnectionResponse?
        if indexPath.section == 0 && todoMessages.count > 0 {
            guard let message = todoMessages[safe: indexPath.row] else { return }
            connection = UserResponse.connections.filter({ return $0.user._id == message.sender || $0.user._id == message.recipient }).first
        } else {
            connection = UserResponse.connections[safe: indexPath.row]
        }
        let conversationVC = MessagesViewController()
        conversationVC.recipient = connection ?? nil
        
        conversationVC.hidesBottomBarWhenPushed = true
        navigationController?.push(conversationVC)
    }

}
