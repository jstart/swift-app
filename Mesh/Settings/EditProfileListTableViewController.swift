//
//  EditProfileListTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/16/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EditProfileListTableViewController: UITableViewController {
    
    var items : [UserDetail] = [Experience(company: "Tinder", position: "iOS", startYear: "2012", endYear: "2016"),
                                Education(schoolName: "Harvard", degreeType: "Masters", startYear: "2012", endYear: "2016"),
                                Skill(name: "iOS Development", numberOfMembers: "2,000 Members", isAdded: true)]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UserDetailTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 70
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return items.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UserDetailTableViewCell.self, indexPath: indexPath)

        let item = items[indexPath.row]
        
        cell.icon.image = #imageLiteral(resourceName: "tesla")
        
        cell.button.isHidden = true
        cell.year.isHidden = !item.hasDate
        
        cell.top.text = item.firstText
        cell.bottom.text = item.secondText
        cell.year.text = item.thirdText
        
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item =  items[indexPath.row]
        guard item.category != .skills else { navigationController?.push(IndustryViewController()); return }
        let detail = EditProfileDetailTableViewController()
        detail.item = item
        navigationController?.push(detail)
    }
}
