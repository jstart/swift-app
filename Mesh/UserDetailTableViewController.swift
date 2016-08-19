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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 5.0
    }
}
