//
//  EventsTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EventsTableViewController : UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    let attending = RealmUtilities.realm().objects(EventResponse.self)//[Event(name: "LA Hacks", date: "Starts October 21", isGoing: true), Event(name: "AWS re:Invent", date: "Starts October 25", isGoing: true)]
    let recommended = [EventResponse]()//RealmUtilities.realm().objects(EventResponse.self)
    let previous = [EventResponse]()//RealmUtilities.realm().objects(EventResponse.self)

    let sectionTitles = ["    YOUR EVENTS", "    RECOMMENDED EVENTS", "    PREVIOUS EVENTS"]

    var searchController : UISearchController?
    var quickCell : UIView?
    let searchResults = InboxSearchTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: searchResults)
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        searchController?.searchBar.placeholder = "Search for events"
        searchController?.searchBar.delegate = self
        
        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        navigationItem.titleView = searchController?.searchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "add"), target: self, action: #selector(add))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.gothamBook(ofSize: 30)], for: .normal)
        tableView.registerNib(ConnectionTableViewCell.self)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)

        let searchField = searchController?.searchBar.value(forKey: "_searchField") as? UITextField
        searchField?.backgroundColor = .white
        searchField?.layer.borderColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        searchField?.layer.borderWidth = 1
        searchField?.layer.cornerRadius = 2.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchController?.searchBar.resignFirstResponder()
        searchController?.isActive = false
    }
    
    func refresh() {
        Client.execute(UpdatesRequest.latest(), complete: { response in
            UpdatesRequest.append(response) { self.tableView.reloadData() }
        })
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { navigationItem.setRightBarButton(nil, animated: true) }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { navigationItem.setRightBarButton(UIBarButtonItem(#imageLiteral(resourceName: "add"), target: self, action: #selector(add)), animated: true) }
    
    open func updateSearchResults(for searchController: UISearchController) {
        let search = searchController.searchResultsController as! InboxSearchTableViewController
        search.view.isHidden = false
        search.showRecents = searchController.searchBar.text == ""
        search.tableView.reloadData()
    }
    
    func add() { navigationController?.push(EventCreateTableViewController()) }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        let attendingCount = Int(attending.count > 0), recommendedCount = Int(recommended.count > 0), previousCount = Int(previous.count > 0)
        return attendingCount + recommendedCount + previousCount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { if section == 0 { return attending.count }; if section == 1 { return recommended.count }; return previous.count }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView().then { $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1) }
        let label = UILabel(translates: false).then {
            $0.text = sectionTitles[section]
            $0.contentMode = .bottomLeft; $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1); $0.font = .gothamBook(ofSize: 12)
        }
        view.addSubview(label)
        label.constrain((.leading, 0), (.trailing, 0), (.bottom, -8), toItem: view)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 40 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath)
        if indexPath.section == 0 { cell.configure(attending[indexPath.row]) }
        if indexPath.section == 1 { cell.configure(recommended[indexPath.row]) }
        if indexPath.section == 2 { cell.configure(previous[indexPath.row]) }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let vc = LiveEventViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.event = attending[indexPath.row]
            navigationController?.push(vc)
        } else if indexPath.section == 1 {
            let vc = LiveEventViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.event = recommended[indexPath.row]
            navigationController?.push(vc)
        } else if indexPath.section == 2 {
            let vc = PastEventTableViewController(style: .grouped)
            vc.event = previous[indexPath.row]
            navigationController?.push(vc)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .default, title: "Unfollow", handler: {_,_ in })]
    }
    
}
