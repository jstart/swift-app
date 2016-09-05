//
//  ContactsTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/25/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import Contacts

class ContactsTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var searchController : UISearchController!
    var contacts = [CNContact]()
    var filteredContacts = [CNContact]()
    var emptyView : EmptyView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Contacts"
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "Search for people"
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        //definesPresentationContext = true
        //navigationItem.titleView = searchController.searchBar
        tableView.tableHeaderView = searchController.searchBar
        
        title = "Contacts"
        tableView.registerNib(ConnectionTableViewCell.self)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close   ", style: .plain, target: self, action: #selector(close))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = ""
        searchController.isActive = false
        searchController.searchBar.becomeFirstResponder()
        guard ContactsManager.authStatus != .authorized else { fetchContacts(); return }
        
        emptyView = EmptyView([AlertAction(title: "Sync Contacts", backgroundColor: AlertAction.defaultBackground, titleColor: .white, handler: {
            self.fetchContacts()
        })], image: #imageLiteral(resourceName: "connectionsAddContacts"))
        emptyView!.titleLabel.text = ContactsManager.authStatus == .denied ? "Permissions Are Turned Off" : "Add Contacts"
        emptyView!.textLabel.text = ContactsManager.authStatus == .denied ? "Contact permissions can be enabled under your iPhone settings for Ripple" : "Find who you already know on Ripple. Connect and stay up to date with them."
        emptyView!.translates = false
        tableView.addSubview(emptyView!)
        emptyView!.constrain(.width, .height, .centerX, .centerY, toItem: tableView)
        tableView.bringSubview(toFront: emptyView!)
    }
    
    func close() { presentingViewController?.dismiss() }
    
    func fetchContacts() {
        let manager = ContactsManager()
        manager.viewController = self
        manager.requestAccess(completionHandler: { authorized in
            guard authorized else { return }
            DispatchQueue.main.async {
                guard let empty = self.emptyView else { return }
                empty.removeFromSuperview()
                self.emptyView = nil
            }
            ContactsManager().allContacts(results: { contactResults in
                self.contacts = contactResults
                self.tableView.reloadData()
            })
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.setRightBarButton(nil, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { }
    
    open func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == "" {
            filteredContacts = contacts
        }else {
            filteredContacts = contacts.filter({return $0.searchText.localizedCaseInsensitiveContains(searchController.searchBar.text!)})
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return emptyView != nil ? 0 : 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "People on Mesh" : "Invite"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return UserResponse.connections?.count ?? 0
        }
        return searchController.isActive ? filteredContacts.count : contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath)
        cell.button.isHidden = false
        cell.company.image = nil
        
        if indexPath.section == 0 {
            let user = UserResponse.connections![indexPath.row]
            cell.name.text = user.fullName()
            cell.title.text = user.fullTitle()
            cell.button.setTitle(" Connect ", for: .normal)
            cell.button.setTitle("Connected", for: .selected)
            cell.buttonHandler = {
                self.connect(user, button: cell.button)
            }
            guard let small = user.photos?.small else {
                let firstName = user.first_name ?? " "
                let lastName = user.last_name ?? " "
                cell.showInitials(firstName: firstName, lastName: lastName)
                return cell
            }
            cell.profile.af_setImage(withURL: URL(string: small)!)
        } else {
            let contact = searchController.isActive ? filteredContacts[indexPath.row] : contacts[indexPath.row]
            cell.name.text = contact.givenName + " " + contact.familyName
            cell.title.text = "Invite Contact"
            cell.button.setTitle("  Add  ", for: .normal)
            cell.button.setTitle(" Added ", for: .selected)
            
            cell.buttonHandler = {
                self.invite(contact, button: cell.button)
            }
            
            guard let data = contact.thumbnailImageData else {
                cell.showInitials(firstName: contact.givenName, lastName: contact.familyName)
                return cell
            }
            cell.profile.image = UIImage(data: data)
        }
        
        return cell
    }
    
    func invite(_ connection: CNContact, button: UIButton) {
        //TODO:
        button.setTitle(" Added ", for: .selected)

    }
    
    func connect(_ connection: UserResponse, button: UIButton) {
        button.setTitle("Connected", for: .selected)
        Client().execute(ConnectionRequest(recipient: connection._id), completionHandler: { _ in
        })
    }

}
