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
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "Search for people"
        searchController.searchBar.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        //tableView.tableHeaderView = searchController.searchBar
        
        title = "Contacts"
        tableView.registerNib(ConnectionTableViewCell.self)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close   ", style: .plain, target: self, action: #selector(close))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = ""
        searchController.isActive = false
        searchController.searchBar.becomeFirstResponder()
        
        emptyView = EmptyView([AlertAction(title: "Sync Contacts", backgroundColor: AlertAction.defaultBackground, titleColor: .white, handler: {
            self.fetchContacts()
        })], image: #imageLiteral(resourceName: "connectionsAddContacts"))
        emptyView!.titleLabel.text = "Add Contacts"
        emptyView!.textLabel.text = "Find who you already know on Ripple. Connect and stay up to date with them."
        emptyView!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView!)
        emptyView!.constrain(.width, .height, .centerX, .centerY, toItem: view)
    }
    
    func close() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func fetchContacts() {
        let manager = ContactsManager()
        manager.viewController = self
        manager.requestAccess(completionHandler: { authorized in
            guard authorized else { return }
            ContactsManager().allContacts(results: { contactResults in
                self.contacts = contactResults
                self.tableView.reloadData()
            })
            guard let empty = self.emptyView else { return}
            empty.removeFromSuperview()
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
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    open func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == "" {
            filteredContacts = contacts
        }else {
            filteredContacts = contacts.filter({return $0.givenName.localizedCaseInsensitiveContains(searchController.searchBar.text!)})
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredContacts.count : contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath) as! ConnectionTableViewCell
        cell.button.isHidden = false
        cell.button.setTitle(" Connect ", for: .normal)
        cell.button.setTitle("Connected", for: .selected)
        
        let contact =  searchController.isActive ? filteredContacts[indexPath.row] : contacts[indexPath.row]
        cell.buttonHandler = {
            self.invite(contact, button: cell.button)
        }
        cell.name.text = contact.givenName + " " + contact.familyName
        cell.company.image = nil
        cell.title.text = contact.organizationName
        guard let data = contact.thumbnailImageData else {
            cell.profile.image = nil
            cell.profile.backgroundColor = .lightGray
            return cell
        }
        cell.profile.image = UIImage(data: data)
        
        return cell
    }
    
    func invite(_ connection: CNContact, button: UIButton) {
        button.layer.borderWidth = button.isSelected ? 1 : 0
        button.isSelected = !button.isSelected
    }
    
    func connect(connection: UserResponse, button: UIButton) {
        Client().execute(ConnectionRequest(recipient: connection._id), completionHandler: { _ in
            button.isSelected = true
        })
    }

}
