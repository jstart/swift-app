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
    var meshContacts = [CNContact]()

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
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        //navigationItem.titleView = searchController.searchBar
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.registerNib(ConnectionTableViewCell.self)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
        tableView.allowsSelection = false
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close   ", style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add All", style: .plain, target: self, action: #selector(addAll))        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.topItem?.title = ""
//        UINavigationBar.appearance().isTranslucent = true

        guard ContactsManager.authStatus != .authorized else { fetchContacts(); return }
        
        emptyView = EmptyView([AlertAction(title: "Sync Contacts", handler: {
            self.fetchContacts()
        })], image: #imageLiteral(resourceName: "connectionsAddContacts"))
        emptyView!.titleLabel.text = ContactsManager.authStatus == .denied ? "Permissions Are Turned Off" : "Add Contacts"
        emptyView!.textLabel.text = ContactsManager.authStatus == .denied ? "Contact permissions can be enabled under your iPhone settings for Mesh" : "Find who you already know on Mesh. Connect and stay up to date with them."
        emptyView!.translates = false
        tableView.addSubview(emptyView!)
        emptyView!.constrain(.width, .height, .centerX, .centerY, toItem: tableView)
        tableView.bringSubview(toFront: emptyView!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
    }
    
    func fetchContacts() {
        let manager = ContactsManager()
        manager.viewController = self
        manager.requestAccess(completionHandler: { authorized in
            guard authorized else { return }
            DispatchQueue.main.async {
                guard let empty = self.emptyView else { return }
                empty.removeFromSuperview(); self.emptyView = nil
            }
            ContactsManager().allContacts(results: { contactResults in
                self.contacts = contactResults
                Client.execute(ContactsSaveRequest(contacts: contactResults), complete: { response in
                    self.fetchMeshContacts()
                })
                self.tableView.reloadData()
            })
        })
    }
    
    func fetchMeshContacts() {
        Client.execute(ContactsRequest(), complete: { response in
            guard let meshPeople = response.result.value as? JSONArray else { return }
            let phoneNumbers = meshPeople.flatMap({return $0["phone_number"]} ) as! [String]
            let emails = meshPeople.flatMap({return $0["email"] }) as! [String]

            self.meshContacts = self.contacts.filter {
                let phone = $0.phoneNumberStrings?.first ?? ""
                let email = $0.emailStrings?.first ?? ""
                return phoneNumbers.contains(phone as String) || emails.contains(email as String)
            }
            self.contacts = self.contacts.filter({return !self.meshContacts.contains($0)})
            self.tableView.reloadData()
        })
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { }
    
    open func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == "" {
            filteredContacts = contacts
        } else {
            filteredContacts = contacts.filter({return $0.searchText.localizedCaseInsensitiveContains(searchController.searchBar.text!)})
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if emptyView != nil { return 0 }
        if meshContacts.count == 0 { return 1 }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if meshContacts.count == 0 { return "Invite" }
        return section == 0 ? "People on Mesh" : "Invite"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && meshContacts.count > 0 { return meshContacts.count }
        return searchController.isActive ? filteredContacts.count : contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath)
        cell.button.isHidden = false
        cell.company.image = nil
        
        let contact : CNContact
        if indexPath.section == 0 && meshContacts.count > 0 {
            contact = meshContacts[indexPath.row]
            cell.title.text = contact.organizationName

            cell.button.setTitle(" Connect ", for: .normal)
            cell.button.setTitle("Connected", for: .selected)
            
            cell.buttonHandler = { self.like(contact) }
        } else {
            contact = searchController.isActive ? filteredContacts[indexPath.row] : contacts[indexPath.row]
            cell.title.text = "Invite Contact"
            cell.button.setTitle("  Add  ", for: .normal)
            cell.button.setTitle(" Added ", for: .selected)
            
            cell.buttonHandler = { self.like(contact) }
        }
        
        cell.name.text = contact.givenName + " " + contact.familyName
        
        guard let data = contact.thumbnailImageData else {
            cell.showInitials(firstName: contact.givenName, lastName: contact.familyName)
            return cell
        }
        cell.profile.image = UIImage(data: data)
        
        return cell
    }
    
    func like(_ contact: CNContact) {
        let phone = contact.phoneNumbers[safe: 0]?.value.value(forKey: "digits") as? String
        let email = contact.emailAddresses[safe: 0]?.value as? String
        Client.execute(LikeContactRequest(phone_number: phone, email: email), complete: { response in })
    }

    func addAll() {
        let actions = [AlertAction(title: "Cancel", backgroundColor: .lightGray, handler: { self.dismiss() }),
                       AlertAction(title: "ADD", handler: { self.dismiss() }) ]
        let alert = AlertViewController(actions, image: #imageLiteral(resourceName: "connectionsAddContacts"))
        let attributedString = NSMutableAttributedString(string: "Are you sure you want to connect and invite everyone in your contact list?")
        let paragraphStyle = NSMutableParagraphStyle(); paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: NSMakeRange(0, attributedString.length))
        alert.textLabel.attributedText = attributedString
        alert.titleLabel.text = "Connect and Add All"
        alert.modalPresentationStyle = .overFullScreen
        present(alert)
    }
    
}
