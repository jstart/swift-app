//
//  AutoCompleteView.swift
//  Mesh
//
//  Created by Christopher Truman on 10/3/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class DetailTableViewCell : UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
    }
}

class AutoCompleteView : UITableView {
    
    func keyboard(notification: Notification) {
        let height = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size.height
        UIView.animate(withDuration: 0.2, animations: {
            self.heightConstraint.constant = height! - 54; self.layoutIfNeeded()
        })
    }
    
    func constrainTo(field: UITextField, inViewController: UIViewController) {
        DefaultNotification.addObserver(self, selector: #selector(keyboard(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
        tableFooterView = UIView()
        registerClass(DetailTableViewCell.self)
        translates = false
        inViewController.view.addSubview(self)
        constrain(.top, constant: 5, toItem: field, toAttribute: .bottom)
        constrain(.width, toItem: inViewController.view)
        constrain(.height, constant: 150)
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: inViewController.view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        reloadData()
    }
}

class AutoCompleteLocationDataSource : NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var didSelect : ((PlacemarkResult?) -> Void) = { _ in }
    
    func filter(_ text: String) { LocationManager.shared.search(text) }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return LocationManager.shared.searchResults.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = LocationManager.shared.searchResults[indexPath.row]
        let cell = tableView.dequeue(DetailTableViewCell.self, indexPath: indexPath)
        cell.textLabel?.text = result.title; cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = LocationManager.shared.searchResults[indexPath.row]
        LocationManager.shared.searchResultToPlacemark(result, completion: didSelect)
    }
    
}

class AutoCompleteDetailDataSource : NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var details = [UserDetail]()
    var didSelect : ((UserDetail) -> Void) = { _ in }
    var didUpdate : ((Void) -> Void) = { _ in }

    func filter(_ text: String) {
        if text.trim == "" { details = [UserDetail](); didUpdate(); return }
        Client.execute(InterestsAutocompleteRequest(q: text)) { response in
            if let interestsJSON = (response.result.value as? JSONArray) {
                self.details = interestsJSON.map({ return InterestResponse.create($0) }); self.didUpdate()
            } else {
                self.details = [UserDetail](); self.didUpdate();
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return details.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detail = details[indexPath.row]
        let cell = tableView.dequeue(DetailTableViewCell.self, indexPath: indexPath)
        cell.textLabel?.text = detail.firstText; cell.detailTextLabel?.text = detail.secondText
        if let logo = detail.logo { cell.imageView?.af_setImage(withURL: URL(string: logo)!) }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { didSelect(details[indexPath.row]) }
    
}
