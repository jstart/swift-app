//
//  SortTableViewController.swift
//  Ripple
//
//  Created by Christopher Truman on 11/11/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SortTableViewController: UITableViewController {

    let sortTitles = ["Recommended", " Distance", "Recently Messaged"]
    let sortImages = [#imageLiteral(resourceName: "sorting"), #imageLiteral(resourceName: "location").withRenderingMode(.alwaysTemplate), #imageLiteral(resourceName: "messageicon").withRenderingMode(.alwaysTemplate)]
    var dismiss = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self)
        tableView.separatorStyle = .none
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated); dismiss()
    }

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return sortTitles.count }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(translates: false).then {
            let label = UILabel(translates: false).then {
                $0.text = "Sort Connections"; $0.constrain((.height, 16)); $0.font = .gothamBold(ofSize: 18)
            }
            $0.addSubview(label)
            label.constrain(.centerY, toItem: $0)
            label.constrain(.leading, constant: 15, toItem: $0)
            $0.constrain((.height, 35))
            let bar = UIView(translates: false).then { $0.constrain((.height, 1)); $0.backgroundColor = .gray }
            $0.addSubview(bar)
            bar.constrain(.bottom, .leading, .trailing, toItem: $0)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 40 }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)

        cell.textLabel?.font = .gothamMedium(ofSize: 18)
        if indexPath.row == 0 {
            cell.textLabel?.textColor = Colors.brand
            cell.imageView?.tintColor = Colors.brand
        } else {
            cell.textLabel?.textColor = .lightGray
            cell.imageView?.tintColor = .lightGray
        }
        cell.textLabel?.text = sortTitles[indexPath.row]
        cell.imageView?.image = sortImages[indexPath.row]
        return cell
    }

}
