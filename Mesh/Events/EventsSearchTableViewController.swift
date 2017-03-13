//
//  EventsSearchTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/23/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EventsSearchTableViewController: UITableViewController {

    var showRecents = true
    var recentSearches = [String]()
    var filteredEvents = [EventResponse]()
    weak var events: EventsTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(ConnectionTableViewCell.self)
        tableView.registerClass(UITableViewCell.self)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        automaticallyAdjustsScrollViewInsets = false
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showRecents ? recentSearches.count : filteredEvents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showRecents {
            let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)
            cell.textLabel?.text = recentSearches[indexPath.row]
            cell.imageView?.image = #imageLiteral(resourceName: "recentSearches")
            return cell
        } else {
            let cell = tableView.dequeue(ConnectionTableViewCell.self, indexPath: indexPath)
            let event = filteredEvents[indexPath.row]
            cell.configure(event)
            
            return cell
        }
    }
    
    func filterBy(text: String) {
        filteredEvents = UserResponse.events.filter({ return $0.name.localizedCaseInsensitiveContains(text) })
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return showRecents }
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            recentSearches.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            guard let events = events else { return }
            events.recentSearches = recentSearches
            StandardDefaults.set(recentSearches, forKey: "RecentEventSearches")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !showRecents else { guard let events = events else { return }
            events.searchController?.searchBar.text = recentSearches[indexPath.row]; return
        }

        let vc = LiveEventViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.event = filteredEvents[indexPath.row]
        presentingViewController?.navigationController?.push(vc)
    }
 
}
