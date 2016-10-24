//
//  PastEventTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/25/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class PastEventTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var searchController : UISearchController!
    var users = [UserResponse]()
    var event: EventResponse?

    var filteredUsers = [UserResponse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = event?.name
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "Search for people"
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        //navigationItem.titleView = searchController.searchBar
        //tableView.tableHeaderView = searchController.searchBar
                
        tableView.registerNib(ConnectionTableViewCell.self)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "overflow"), target: self, action: #selector(overflow))
        
        tableView.tableHeaderView = UIView(translates: false).then {
            $0.backgroundColor = .white
            
            let name = UILabel().then {
                $0.textColor = .darkGray; $0.font = .gothamBold(ofSize: 20)
                $0.text = event?.name
            }
            let subtitle = UILabel().then {
                $0.textColor = .lightGray; $0.font = .gothamBook(ofSize: 12)
                $0.text = event?.secondText
            }
            let titleStack = UIStackView(name, subtitle, axis: .vertical, spacing: 5).then { $0.distribution = .fillProportionally; $0.alignment = UIStackViewAlignment.leading }
            
            let logo = UIImageView(image: .imageWithColor(.gray, width: 85, height: 85)).then { $0.layer.cornerRadius = 5; $0.clipsToBounds = true }
            logo.constrain((.width, 85), (.height, 85))
            if let logoURL = event?.logo { logo.af_setImage(withURL: URL(string: logoURL)!) }
            let stack = UIStackView(logo, titleStack, spacing: 10).then { $0.distribution = .fillProportionally }

            $0.addSubview(stack)
            
            stack.translates = false
            stack.constrain((.leading, 10), (.trailing, -10), (.centerY, 0), toItem: $0)
            $0.constrain((.height, 120))
        }
        tableView.tableHeaderView?.constrain(.leading, .trailing, .width, .top, toItem: tableView)
        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.tableHeaderView = tableView.tableHeaderView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
    }
    
    func fetchUsers() {
        users = RealmUtilities.objects(UserResponse.self)
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.setRightBarButton(nil, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { }
    
    open func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == "" {
            filteredUsers = users
        }else {
            filteredUsers = users.filter({return $0.searchText().localizedCaseInsensitiveContains(searchController.searchBar.text!)})
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return "Missed Connections" }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.count > 0 { return users.count }
        return searchController.isActive ? filteredUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath)
        cell.button.isHidden = false
        cell.company.image = nil
        
        let user = users[indexPath.row]
        cell.name.text = user.fullName()
        cell.title.text = user.fullTitle()
        cell.button.setTitle(" Connect ", for: .normal); cell.button.setTitle("Connected", for: .selected)
        cell.buttonHandler = { self.like(user) }
        cell.showInitials(firstName: user.first_name!, lastName: user.last_name!)
        
        return cell
    }
    
    func overflow() { }
    
    func like(_ contact: UserResponse) {
        //let phone = contact.phoneNumbers[safe: 0]?.value.value(forKey: "digits") as? String
        //let email = contact.emailAddresses[safe: 0]?.value as? String
        //Client.execute(LikeContactRequest(phone_number: phone, email: email), complete: { response in })
    }

}
