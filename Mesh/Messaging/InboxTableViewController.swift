//
//  InboxTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class InboxTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {

    var searchController : UISearchController?
    let searchResults = InboxSearchTableViewController()
    var sortItem : UIBarButtonItem?
    var addItem : UIBarButtonItem?
    var todoMessages = [MessageResponse]()
    var recentSearches = (StandardDefaults["RecentConnectionSearches"] as? [String]) ?? [String]()
    
    var messages = [MessageResponse]()
    var connections = [ConnectionResponse]()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        searchController = UISearchController(searchResultsController: searchResults)
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        searchController?.searchBar.placeholder = "Search for people"
        searchController?.searchBar.delegate = self
        
        let searchField = searchController?.searchBar.value(forKey: "_searchField") as? UITextField
        searchField?.backgroundColor = .white
        searchField?.layer.borderColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        searchField?.layer.borderWidth = 1
        searchField?.layer.cornerRadius = 2.5

        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        navigationItem.titleView = searchController?.searchBar
        sortItem = UIBarButtonItem(#imageLiteral(resourceName: "sorting"), target: self, action: #selector(sort))
        addItem = UIBarButtonItem(#imageLiteral(resourceName: "addFriends"), target: self, action: #selector(add))
        navigationItem.rightBarButtonItems = [sortItem!, addItem!]
        tableView.registerNib(ConnectionTableViewCell.self, MessageTableViewCell.self, MessagePreviewTableViewCell.self)

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        
        searchResults.recentSearches = recentSearches
        searchResults.inbox = self
        
        DefaultNotification.addObserver(self, selector: #selector(receivedMessage(notification:)), name: .message, object: nil)
        DefaultNotification.addObserver(self, selector: #selector(receivedConnection(notification:)), name: .connection, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        processToDo()
        self.tableView.reloadData()
        
        refresh()
    }
    
    func processToDo() {
        let valid = UserResponse.messages.filter({ message in
            let connection = UserResponse.connections.filter({ connection in return connection.user!._id == message.sender }).first
            return !(connection?.read ?? true) &&
                message.sender != UserResponse.current?._id &&
                message.text != ""
        })
        if let first = valid.first {
            self.todoMessages = [first]
            if let second = valid.filter({$0.sender != first.sender && $0.text != ""}).first {
                self.todoMessages.append(second)
            }
        } else { self.todoMessages = [] }
    }
    
    func refresh() {
        Client.execute(UpdatesRequest.latest(), complete: { response in
            //TODO: updates won't reflect read/unread state unless we fetch a fresh copy of everything
            UpdatesRequest.append(response) { self.processToDo(); self.tableView.reloadData() }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchController?.searchBar.resignFirstResponder(); searchController?.isActive = false
        tableView.reloadData()
    }
    
    func receivedMessage(notification: Notification) { refresh() }
    func receivedConnection(notification: Notification) { refresh() }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { navigationItem.setRightBarButtonItems(nil, animated: true) }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { self.navigationItem.setRightBarButtonItems([self.sortItem!, self.addItem!], animated: true) }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        guard let text = searchBar.text else { return true }; guard text != "" else { return true }
        if !recentSearches.contains(text) {
            recentSearches.append(text)
            searchResults.recentSearches = recentSearches
            StandardDefaults.set(recentSearches, forKey: "RecentConnectionSearches")
        }
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
//        return
        (navigationItem.rightBarButtonItems?[0].image = #imageLiteral(resourceName: "sortConnectionsClose"))!
        let pop = SortTableViewController()
        pop.dismiss = {
            (self.navigationItem.rightBarButtonItems?[0].image = #imageLiteral(resourceName: "sorting"))!
        }
        pop.preferredContentSize = CGSize(width: view.frame.size.width - 20, height: 175)
        pop.modalPresentationStyle = .popover
        pop.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?[0]
        pop.popoverPresentationController?.delegate = self
        present(pop)
    }
    
    func add() { navigationController?.push(ContactsTableViewController(style: .grouped)) }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { return .none }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return todoMessages.count > 0 ? 2 : 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if todoMessages.count > 0 && section == 0 { return todoMessages.count }
        return section == 0 && todoMessages.count > 0 ? todoMessages.count : UserResponse.connections.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView().then { $0.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1) }
        let label =  UILabel(translates: false).then {
            $0.text = section == 0 && todoMessages.count > 0 ? "    TO DO" : "    " + String(UserResponse.connections.count ) + " CONNECTION"
            if UserResponse.connections.count > 1 || UserResponse.connections.count == 0 { $0.text = $0.text! + "S" }
            $0.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
            $0.contentMode = .bottomLeft
            $0.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1); $0.font = .gothamBook(ofSize: 12)
        }
        view.addSubview(label)
        label.constrain((.leading, 0), (.trailing, 0), (.bottom, -8), toItem: view)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 40 }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && todoMessages.count > 0 {
            guard let message = todoMessages[safe: indexPath.row] else { return UITableViewCell() }
            guard let connection = UserResponse.connections.filter({ return $0.user!._id == message.sender }).first else { return UITableViewCell() }
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
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
            cell.skip.callback = { sender in
                let currentIndex = tableView.indexPath(for: sender!)!
                self.todoMessages.remove(at: currentIndex.row)
                if self.todoMessages.count == 0 {
                    tableView.deleteSections([indexPath.section], with: .automatic)
                } else {
                    tableView.deleteRows(at: [currentIndex], with: .automatic)
                }
                Client.execute(MarkReadRequest(read: !connection.read, id: connection.user!._id), complete: { _ in
                    connection.write { $0.read = !$0.read }; self.refresh()
                })
                return false
            }
            cell.leftButtons = [cell.skip]
            
            cell.read.callback = { _ in
                cell.add(read: !connection.read)
                Client.execute(MarkReadRequest(read: !connection.read, id: connection.user!._id), complete: { _ in
                    connection.write { $0.read = !$0.read }; self.refresh()
                })
                return true
            }
            cell.mute.callback = { sender in return true }
            cell.block.callback = { sender in
                Client.execute(ConnectionDeleteRequest(connection_id: connection._id))
                UserResponse.connections.remove(at: indexPath.row); connection.delete()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                return true
            }
            cell.rightButtons = [cell.read, cell.mute, cell.block]
            cell.configure(message.text, user: connection.user!, read: connection.read)
            cell.pressedAction = ({ self.presentQuickReply(connection: connection, message: message, index: indexPath) })
            
            cell.add(message: message, read: connection.read)
            return cell
        } else {
            let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath)
            guard let connection = UserResponse.connections[safe: indexPath.row] else { return cell }
            cell.configure(connection.user)
            let title = connection.read ? "Mark Unread" : "Mark Read"
            cell.read.titleLabel?.text = title
            cell.read.callback = { _ in
                cell.add(read: !connection.read)
                Client.execute(MarkReadRequest(read: !connection.read, id: connection.user!._id), complete: { _ in
                    connection.write { $0.read = !$0.read }; self.refresh()
                })
                return true
            }
            cell.mute.callback = { sender in return true }
            cell.block.callback = { sender in
                Client.execute(ConnectionDeleteRequest(connection_id: connection._id))
                UserResponse.connections.remove(at: indexPath.row); connection.delete()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                return true
            }
            cell.rightButtons = [cell.read, cell.mute, cell.block]
            
            let message = UserResponse.messages.filter({ return $0.recipient == connection.user!._id || $0.sender == connection.user!._id })[safe: 0]
            cell.add(message: message, read: connection.read)
            return cell
        }
    }
    
    func presentQuickReply(connection: ConnectionResponse, message: MessageResponse, index: IndexPath) {
        let cell = tableView.cellForRow(at: index)
        cell?.removeFromSuperview()
        UIApplication.shared.delegate?.window??.addSubview(cell!)
        UIView.animate(withDuration: 0.2, animations: {
            cell?.frame.origin.y = 0
            }, completion: { _ in
                cell?.fadeOut {
                    cell?.removeFromSuperview(); self.tableView.reloadRows(at: [index], with: .fade); self.refresh()
                }
        })
        
        let quickReply = QuickReplyViewController(connection.user, text: message.text!, date: message.ts)
        quickReply.modalPresentationStyle = .overFullScreen
        quickReply.action = { text in Client.execute(MessagesSendRequest(recipient: message.sender, text: text!), complete: { response in
            Client.execute(MarkReadRequest(read: !connection.read, id: connection.user!._id), complete: { _ in
                connection.write { $0.read = !$0.read }; self.refresh()
            })
            self.todoMessages.remove(at: index.row);
            if self.todoMessages.count > 0 { self.tableView.deleteRows(at: [index], with: .automatic); self.refresh() } else { self.refresh() }
        }) }
        present(quickReply)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var connection: ConnectionResponse?
        if indexPath.section == 0 && todoMessages.count > 0 {
            guard let message = todoMessages[safe: indexPath.row] else { return }
            connection = UserResponse.connections.filter({ return $0.user?._id == message.sender}).first
        } else {
            connection = UserResponse.connections[safe: indexPath.row]
        }
        guard let safeConnection = connection else { return }
        let conversationVC = MessagesViewController()
        conversationVC.recipient = safeConnection
        
        conversationVC.hidesBottomBarWhenPushed = true
        navigationController?.push(conversationVC)
    }

}
