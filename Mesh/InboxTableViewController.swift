//
//  InboxTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class InboxTableViewController: UITableViewController {

    let searchBar = { () -> UISearchBar in 
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for people and messages"
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = searchBar
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.8196078431, green: 0.8196078431, blue: 0.8196078431, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "sorting"), style: .plain, target: self, action: #selector(sort))
        
        Client().execute(MessagesSendRequest(recipient: "57b63c7f887fb1b3571666b5", text: "POOP"), completionHandler: { response in
            print("JSON: \(response.result.value)")
            print(response.result.error)
        })
    }
    
    func sort() {
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 258
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "2 new messages" : "258 Connections"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = "test"
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationVC = ConversationViewController()
        conversationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(conversationVC, animated: true)
    }

}
