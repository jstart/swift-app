//
//  EventsTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EventsTableViewController : UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var searchController : UISearchController!
    var quickCell : UIView?
    let searchResults = InboxSearchTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: searchResults)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "Search for events"
        searchController.searchBar.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        navigationItem.titleView = searchController.searchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "sorting"), target: self, action: #selector(sort))
        tableView.registerNib(ConnectionTableViewCell.self)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { navigationItem.setRightBarButton(nil, animated: true) }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        navigationItem.setRightBarButton(UIBarButtonItem(#imageLiteral(resourceName: "sorting"), target: self, action: #selector(sort)), animated: true)
    }
    
    open func updateSearchResults(for searchController: UISearchController) {
        let search = searchController.searchResultsController as! InboxSearchTableViewController
        search.view.isHidden = false
        search.showRecents = searchController.searchBar.text == ""
        search.tableView.reloadData()
    }
    
    func sort() { }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "TOPICS" : "PREVIOUS EVENTS"
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UILabel().then {
            $0.text = section == 0 ? "    TOPICS" : "    PREVIOUS EVENTS"
            $0.backgroundColor  = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
            $0.font = .systemFont(ofSize: 12)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath)
        cell.name.text = "Java"
        cell.title.text = nil
        cell.profile.image = #imageLiteral(resourceName: "tesla")
        cell.company.image = nil
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .default, title: "Unfollow", handler: {_,_ in })]
    }
}