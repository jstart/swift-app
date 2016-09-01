//
//  EditCardView.swift
//  Mesh
//
//  Created by Christopher Truman on 8/31/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class EditCardView : CardView, UITableViewDelegate, UITableViewDataSource {
    
    var cancelHandler : (() -> Void)?
    var doneHandler : (() -> Void)?

    let tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.registerClass(EditCardTableViewCell.self)
    }
    
    let cancel = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("CANCEL", for: .normal)
        $0.backgroundColor = .lightGray
        $0.setTitleColor(.white, for: .normal)
        $0.constrain(.height, constant: 50)
    }
    
    let done = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("DONE", for: .normal)
        $0.backgroundColor = AlertAction.defaultBackground
        $0.setTitleColor(.white, for: .normal)
        $0.constrain(.height, constant: 50)
    }
    
    convenience init(_ user: UserResponse) {
        self.init()
        clipsToBounds = true
        layer.shadowColor = UIColor.clear.cgColor
        addSubviews(tableView, cancel, done)
        tableView.dataSource = self
        tableView.delegate = self
        
        cancel.addTarget(self, action: #selector(cancelPressed(sender:)), for: .touchUpInside)
        done.addTarget(self, action: #selector(donePressed(sender:)), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.constrain(.width, .centerX, .top, toItem: self)
        tableView.constrain(.height, constant: -50, toItem: self)
        cancel.constrain(.leading, toItem: self)
        cancel.constrain(.trailing, toItem: done, toAttribute: .leading)
        done.constrain(.trailing, toItem: self)
        cancel.constrain(.bottom, toItem: self)
        done.constrain(.bottom, toItem: self)
        cancel.constrain(.width, toItem: done)
        tableView.reloadData()
    }
    
    func cancelPressed(sender: UIButton){ cancelHandler?()  }
    
    func donePressed(sender: UIButton){ doneHandler?() }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(EditCardTableViewCell.self, indexPath: indexPath) as! EditCardTableViewCell
        cell.contactField.text = "Greg Blatt"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EditCardTableViewCell
        cell.check(true)
    }
}
