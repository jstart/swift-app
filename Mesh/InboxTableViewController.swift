//
//  InboxTableViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class InboxTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UIPopoverPresentationControllerDelegate {

    var searchController : UISearchController!
    var quickCell : UIView?
    var field : UITextField = UITextField()
    let searchResults = InboxSearchTableViewController()
    var sortItem : UIBarButtonItem?
    var addItem : UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: searchResults)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "Search for people and messages"
        searchController.searchBar.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        navigationItem.titleView = searchController.searchBar
        sortItem = UIBarButtonItem(image: #imageLiteral(resourceName: "sorting"), style: .plain, target: self, action: #selector(sort))
        addItem = UIBarButtonItem(image: #imageLiteral(resourceName: "addFriends"), style: .plain, target: self, action: #selector(add))
        navigationItem.rightBarButtonItems = [sortItem!, addItem!]
        //Client().execute(ConnectionRequest(recipient: "57ba725d87223ad6215ecaf9"), completionHandler: { _ in})
        /*Client().execute(MessagesSendRequest(recipient: "57b63c7f887fb1b3571666b5", text: "POOP"), completionHandler: { response in
            print("JSON: \(response.result.value)")
            print(response.result.error)
        })*/
        tableView.register(ConnectionTableViewCell.self, MessageTableViewCell.self)

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.setRightBarButtonItems(nil, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        navigationItem.rightBarButtonItems = [sortItem!, addItem!]
    }
    
    open func updateSearchResults(for searchController: UISearchController) {
        let search = searchController.searchResultsController as! InboxSearchTableViewController
        search.view.isHidden = false
        search.showRecents = searchController.searchBar.text == ""
        search.tableView.reloadData()
    }
    
    func sort() {
        //navigationItem.rightBarButtonItems?[0].image = #imageLiteral(resourceName: "sortConnectionsClose")
        let pop = UITableViewController()
        pop.preferredContentSize = CGSize(width: view.frame.size.width - 20, height: 210)
        pop.modalPresentationStyle = .popover
        pop.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?[0]
        pop.popoverPresentationController?.delegate = self
        present(pop, animated: true, completion: nil)
    }
    
    func add() {
        navigationController?.pushViewController(ContactsTableViewController(), animated: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UILabel().then {
            $0.text = section == 0 ? "    TO DO" : "    258 CONNECTIONS"
            $0.backgroundColor  = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
            $0.font = .systemFont(ofSize: 12)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
            cell.name.text = "Elon Musk"
            cell.profile.image = #imageLiteral(resourceName: "profile_sample")
            cell.company.image = #imageLiteral(resourceName: "tesla")
            cell.message.text = "The new discounting feature for Tinder is going well. Subs are up by 14%. Things going as planned, super good, hooray"
            cell.pressedAction = ({
                if self.quickCell == nil {
                    self.quickCell = self.quickReplyView()
                }
                let window = UIApplication.shared.delegate!.window!
                if (window?.subviews.contains(self.quickCell!))! {
                    return
                }
                self.quickCell!.alpha = 0.0
                UIApplication.shared.delegate!.window!?.addSubview(self.quickCell!)

                UIView.animate(withDuration: 0.2, animations: {
                    UIApplication.shared.delegate?.window??.windowLevel = UIWindowLevelStatusBar + 1
                    //UIApplication.shared.isStatusBarHidden = true
                    self.quickCell!.alpha = 1.0
                    self.quickCell!.constrain(.width, .height, .top, .leading, toItem: window)
                    self.field.becomeFirstResponder()
                })
            })
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionTableViewCell", for: indexPath) as! ConnectionTableViewCell
            cell.name.text = "Elon Musk"
            cell.profile.image = #imageLiteral(resourceName: "profile_sample")
            cell.company.image = #imageLiteral(resourceName: "tesla")

            return cell
        }
    }
    
    func quickReplyView() -> UIView {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! MessageTableViewCell
        
        cell.contentView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.backgroundColor = .white
        cell.reply.isHidden = true
        cell.name.text = "Elon Musk"
        cell.profile.image = #imageLiteral(resourceName: "profile_sample")
        cell.company.image = #imageLiteral(resourceName: "tesla")
        cell.message.text = "The new discounting feature for Tinder is going well. Subs are up by 14%. Things going as planned, super good, hooray"
        cell.message.numberOfLines = 2
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        let tapGeesture = UITapGestureRecognizer(target: self, action: #selector(dismissQuickReply))
        blurView.addGestureRecognizer(tapGeesture)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.addSubview(cell.contentView)
        cell.contentView.constrain(.width, .top, .leading, toItem: blurView)
        
        field.placeholder = "Send a message..."
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        spacer.backgroundColor = .white
        field.leftView = spacer;
        
        let right = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 15))
        right.setTitleColor(.lightGray, for: .normal)
        right.setTitle("Send", for: .normal)
        field.rightView = right
        
        field.rightViewMode = .always
        field.leftViewMode = .always
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1.0
        field.backgroundColor = .white
        field.translatesAutoresizingMaskIntoConstraints = false
        blurView.addSubview(field)
        field.constrain(.height, constant: 50)
        field.constrain(.width, constant: 2, toItem: cell.contentView)
        field.constrain(.leading, constant: -1, toItem: cell.contentView)
        NSLayoutConstraint(item: field, attribute: .top, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        return blurView
    }
    
    func dismissQuickReply() {
        UIView.animate(withDuration: 0.2, animations: {
            UIApplication.shared.delegate?.window??.windowLevel = UIWindowLevelNormal
            //UIApplication.shared.isStatusBarHidden = false
            self.quickCell!.alpha = 0.0
            self.field.resignFirstResponder()
        }, completion: { _ in
            self.quickCell!.removeFromSuperview()
        })
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let conversationVC = ConversationViewController()
                
            conversationVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(conversationVC, animated: true)
        } else {
            let details = UserDetails(connections: [], experiences: [], educationItems: [], skills: [], events: [])
            let person = Person(user: nil, details: details)
            
            let cardVC = CardViewController()
            cardVC.card = Card(type:.person, person: person)
            cardVC.modalPresentationStyle = .overFullScreen
            present(cardVC, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .default, title: "Mark Unread", handler: {_,_ in })]
    }

}
