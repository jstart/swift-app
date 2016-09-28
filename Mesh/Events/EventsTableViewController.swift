//
//  EventsTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EventsTableViewController : UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    let attending = [Event(name: "LA Hacks", date: "Starts October 21", isGoing: true), Event(name: "AWS re:Invent", date: "Starts October 25", isGoing: true)]
    let recommended = [Event(name: "Techcrunch Disrupt", date: "", isGoing: true)]

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
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { navigationItem.setRightBarButton(UIBarButtonItem(#imageLiteral(resourceName: "sorting"), target: self, action: #selector(sort)), animated: true) }
    
    open func updateSearchResults(for searchController: UISearchController) {
        let search = searchController.searchResultsController as! InboxSearchTableViewController
        search.view.isHidden = false
        search.showRecents = searchController.searchBar.text == ""
        search.tableView.reloadData()
    }
    
    func sort() { }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return section == 0 ? attending.count : recommended.count }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UILabel().then {
            $0.text = section == 0 ? "    YOUR EVENTS" : "    RECOMMENDED EVENTS"
            $0.contentMode = .bottomLeft
            $0.backgroundColor  = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1); $0.font = .proxima(ofSize: 12)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 50 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath)
        if indexPath.section == 0 { cell.configure(attending[indexPath.row]) }
        if indexPath.section == 1 { cell.configure(recommended[indexPath.row]) }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .default, title: "Unfollow", handler: {_,_ in })]
    }
}
