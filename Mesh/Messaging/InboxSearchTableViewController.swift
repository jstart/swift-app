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
    var filteredConnections = [UserResponse]()
    weak var inbox: InboxTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(ConnectionTableViewCell.self)
        tableView.registerClass(UITableViewCell.self)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showRecents ? recentSearches.count : filteredConnections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showRecents {
            let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
            cell.textLabel?.text = recentSearches[indexPath.row]
            cell.imageView?.image = #imageLiteral(resourceName: "recentSearches")
            return cell
        } else {
            let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath)
            cell.profile.image = .imageWithColor(.gray)
            cell.company.image = #imageLiteral(resourceName: "tesla")
            
            let connection = filteredConnections[indexPath.row]
            cell.configure(connection)
            
            return cell
        }
    }
    
    func filterBy(text: String) {
        filteredConnections = UserResponse.connections.map({ return $0.user }).filter({return $0.searchText().localizedCaseInsensitiveContains(text)}) 
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
            inbox.searchController.searchBar.text = recentSearches[indexPath.row]; return
        }
        let details = UserDetails(connections: [], experiences: [], educationItems: [], skills: [], events: [])
        let person = Person(user: filteredConnections[indexPath.row], details: details)
        
        let cardVC = CardViewController()
        cardVC.card = Rec(type:.person, person: person)
        cardVC.modalPresentationStyle = .overFullScreen
        present(cardVC)
    }
 
}
