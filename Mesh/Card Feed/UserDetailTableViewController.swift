//
//  UserDetailTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class UserDetailTableViewController : UITableViewController {
    
    var details : [UserDetail]?
    var category : QuickViewCategory?
    var index : Int?
    var dismissHandler : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UserDetailTableViewCell.self)
        view.layer.cornerRadius = 10.0
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 70
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return category?.rawValue
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UILabel().then {
            $0.text = "     " + (category?.title().uppercased() ?? "")
            $0.textColor = .lightGray
            $0.backgroundColor = .white
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return details!.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UserDetailTableViewCell.self, indexPath: indexPath)
        let detail = details![indexPath.row]
        cell.configure(detail)
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -20 { dismissHandler?() }
    }
}
