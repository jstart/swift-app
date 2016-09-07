//
//  InboxSearchTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/23/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class InboxSearchTableViewController: UITableViewController {

    var showRecents = true
    var recentSearches = [String]()
    var filteredConnections : [UserResponse]?
    weak var inbox: InboxTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(ConnectionTableViewCell.self)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showRecents ? recentSearches.count : filteredConnections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showRecents {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            cell.textLabel?.text = recentSearches[indexPath.row]
            cell.imageView?.image = #imageLiteral(resourceName: "recentSearches")
            return cell
        } else {
            let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath)
            cell.profile.image = #imageLiteral(resourceName: "profile_sample")
            cell.company.image = #imageLiteral(resourceName: "tesla")
            
            guard let connection = filteredConnections?[indexPath.row] else { return cell }
            cell.configure(connection)
            
            return cell
        }
    }
    
    func filterBy(text: String) {
        filteredConnections =  UserResponse.connections?.filter({return $0.searchText().localizedCaseInsensitiveContains(text)})
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return showRecents }
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            recentSearches.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            guard let inbox = inbox else { return }
            inbox.recentSearches = recentSearches
            UserDefaults.standard.set(recentSearches, forKey: "RecentConnectionSearches")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !showRecents else {
            guard let inbox = inbox else { return }
            let search = recentSearches[indexPath.row]
            inbox.searchController.searchBar.text = search
            return
        }
        guard let connection = filteredConnections?[indexPath.row] else { return }

        let details = UserDetails(connections: [], experiences: [], educationItems: [], skills: [], events: [])
        let person = Person(user: connection, details: details)
        
        let cardVC = CardViewController()
        cardVC.card = Card(type:.person, person: person)
        cardVC.modalPresentationStyle = .overFullScreen
        present(cardVC)
    }
 
}
