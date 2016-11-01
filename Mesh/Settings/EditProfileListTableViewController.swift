//
//  EditProfileListTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EditProfileListTableViewController: UITableViewController {
    
    var items : [UserDetail] = []
    var itemType : QuickViewCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit " + items.first!.category.title()
        
        tableView.registerNib(UserDetailTableViewCell.self); tableView.registerClass(AddItemTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 70
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return items.count + 1 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == items.count {
            let cell = tableView.dequeue(AddItemTableViewCell.self, indexPath: indexPath)
            cell.configure(items.first!.category.title())
            cell.constrain((.height, 85))
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
            return cell
        }
        
        let cell = tableView.dequeue(UserDetailTableViewCell.self, indexPath: indexPath)
        let item = items[indexPath.row]
        cell.configure(item)
        
        if item.category == .skills {
            cell.deleteHandler = { }
            cell.delete.isHidden = false
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard items.first!.category != .skills else { navigationController?.push(SkillsViewController()); return }

        let detail = EditProfileDetailTableViewController()
        detail.itemType = itemType
        if indexPath.row != items.count { detail.item = items[indexPath.row] }
        
        navigationController?.push(detail)
    }
    
}
