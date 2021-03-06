//
//  SkillsViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SkillsViewController: UIViewController, UICollectionViewDelegate, UISearchBarDelegate {
     
    let layout = UICollectionViewFlowLayout().then {
        let size = UIApplication.shared.keyWindow?.frame.size
        $0.itemSize = CGSize(width: size!.width * (120/414), height: size!.width * (120/414))
    }
    lazy var collectionView : UICollectionView = {
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout).then {
            $0.translates = false; $0.backgroundColor = .white
            $0.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }()
    let complete = UIButton(translates: false).then {
        $0.setBackgroundImage(.imageWithColor(Colors.brand), for: .normal)
        $0.setBackgroundImage(.imageWithColor(.lightGray), for: .disabled)
        $0.isEnabled = true
        $0.titleLabel?.font = .gothamMedium(ofSize: 20); $0.titleColor = .white
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.title = "NEXT"
        $0.layer.cornerRadius = 5; $0.clipsToBounds = true
        $0.constrain((.height, 50))
    }
    let addSkills = UIButton(translates: false).then {
        $0.isEnabled = false
        $0.setBackgroundImage(.imageWithColor(.lightGray), for: .normal)
        $0.titleLabel?.font = .gothamMedium(ofSize: 20); $0.titleColor = .white
        $0.setTitle("ADD MORE", for: .normal)
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.layer.cornerRadius = 5; $0.clipsToBounds = true
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        $0.constrain((.height, 50))
    }
    let completeView = UIView(translates: false).then {
        $0.backgroundColor = .white
        $0.layer.shadowColor = UIColor.lightGray.cgColor
        $0.layer.shadowOpacity = 1.0; $0.layer.shadowRadius = 5
    }
    var indexPath : IndexPath?
    
    lazy var dataSource : IndustriesCollectionViewDataSource = { return IndustriesCollectionViewDataSource(self.collectionView) }()
    var pickerItems : [PickerResponse]?
    var industryMode = true
    
    var selectedPickerItems = [PickerResponse]()
    let search = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Select Industry"
        
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        collectionView.constrain(.centerX, .centerY, .width, .height, toItem: view)
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(openSearch))
        search.delegate = self
        search.showsCancelButton = true
        
        if Token.retrieveLogin().phone_number == nil {
            Token.deleteToken()
        }
        
        view.addSubview(completeView)
        
        completeView.constrain(.leading, .trailing, .bottom, toItem: view)
        
        completeView.addSubviews(addSkills, complete)
        
        addSkills.constrain(.leading, constant: 10, toItem: completeView)
        addSkills.constrain(.trailing, constant: -10, toItem: complete, toAttribute: .leading)
        addSkills.constrain((.bottom, -10), (.top, 10), toItem: completeView)
        
        complete.constrain(.trailing, constant: -10, toItem: completeView)
        complete.constrain(.width, toItem: addSkills)
        complete.constrain((.bottom, -10), (.top, 10), (.trailing, -10), toItem: completeView)
        
        addSkills.addTarget(self, action: #selector(switchToIndustries), for: .touchUpInside)
        complete.addTarget(self, action: #selector(toFeed), for: .touchUpInside)
        
        collectionView.contentInset = UIEdgeInsets(top: collectionView.contentInset.top, left: collectionView.contentInset.left, bottom: 80, right: collectionView.contentInset.right)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)

        if Token.retrieveToken() == nil { Client.execute(TokenRequest()) { _ in
                self.pickerRequest()
            }
        } else {
            self.pickerRequest()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let alert = TopAlert(title: "New Message", content: "Does Wednesday or Thursday work for you?", imageURL: "https://scontent-lax3-1.xx.fbcdn.net/v/t1.0-9/13557660_10208640811569109_1312730316583649784_n.jpg?oh=b4744f845cf58e30f671951e43d9b799&oe=589244EB", duration: 5)
        alert.actions = [AlertAction(title: "Reply")]
        //alert.presentIn(UIApplication.shared.delegate!.window!)
    }
    
    func pickerRequest() {
        Client.execute(PickerRequest()) { response in
            if let pickerJSON = response.result.value as? JSONArray {
                let interests = pickerJSON.map({ return PickerResponse.create($0) })
                let dataSource = IndustriesCollectionViewDataSource(self.collectionView)
                self.pickerItems = interests
                dataSource.pickerItems = interests
                self.dataSource = dataSource
                self.collectionView.dataSource = dataSource
                self.collectionView.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSource.filter(searchText)
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { enterSearch(false) }
    func openSearch() { enterSearch(true) }
    
    func enterSearch(_ open: Bool) {
        if !open {
            search.text = ""
            search.resignFirstResponder()
            dataSource.searching = false
            collectionView.reloadSections(IndexSet(integer: 0))
            //navigationItem.setRightBarButtonItems([UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(openSearch))], animated: true)
            navigationItem.titleView = nil
        } else {
            navigationItem.setRightBarButton(nil, animated: true)
            dataSource.searching = true
            navigationItem.titleView = search
            search.becomeFirstResponder()
        }
    }
    
    //func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { cell.scaleIn(delay: 0.5) }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) { collectionView.cellForItem(at: indexPath)?.squeezeIn() }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.squeezeOut()
//        if self.title != "Select Industry" {
//            let pickerItem = dataSource.itemFor(indexPath: indexPath)
//            for (index, item) in selectedPickerItems.enumerated() {
//                if item == pickerItem {
//                    selectedPickerItems.remove(at: index)
//                }
//            }
//            dataSource.selectedPickerItems = selectedPickerItems
//        } else {
//            guard let pickerItem = dataSource.itemFor(indexPath: indexPath) else { return }
//            if pickerItem.children.count == 0 { collectionView.deselectItem(at: indexPath, animated: true); return }
//            self.switchToSkills(indexPath)
//        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if industryMode {
            guard let pickerItem = dataSource.itemFor(indexPath: indexPath) else { return }
            if pickerItem.children.count == 0 { collectionView.deselectItem(at: indexPath, animated: true); return }
            self.switchToSkills(indexPath)
        } else {
            guard let pickerItem = dataSource.itemFor(indexPath: indexPath) else { return }
            selectedPickerItems.append(pickerItem)
            dataSource.selectedPickerItems = selectedPickerItems
            if dataSource.selectedPickerItems.count == 1 {
                title = "\(dataSource.selectedPickerItems.count) interest selected"
            } else {
                title = "\(dataSource.selectedPickerItems.count) interests selected"
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.squeezeInOut()
        if !industryMode {
            let pickerItem = dataSource.itemFor(indexPath: indexPath)
            for (index, item) in selectedPickerItems.enumerated() {
                if item == pickerItem && selectedPickerItems.count >= index {
                    selectedPickerItems.remove(at: index)
                }
            }
            dataSource.selectedPickerItems = selectedPickerItems
            if dataSource.selectedPickerItems.count == 1 {
                title = "\(dataSource.selectedPickerItems.count) interest selected"
            } else {
                title = "\(dataSource.selectedPickerItems.count) interests selected"
            }
        } else {
            guard let pickerItem = dataSource.itemFor(indexPath: indexPath) else { return }
            if pickerItem.children.count == 0 { collectionView.deselectItem(at: indexPath, animated: true); return }
            self.switchToSkills(indexPath)
        }
    }
    
    func switchToIndustries() {
        search.resignFirstResponder()

        addSkills.isEnabled = false
        collectionView.allowsSelection = false
        navigationItem.backBarButtonItem = nil
        animateCells(self.indexPath!, reverse: true)
        
        dataSource.pickerItems = pickerItems!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            self.collectionView.reloadSections(IndexSet(integer: 0))
        })
        industryMode = true; swap()
        navigationItem.leftBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "backArrow"), target: navigationController!, action: #selector(UINavigationController.popViewController(animated:)))
        collectionView.allowsMultipleSelection = true
        collectionView.allowsSelection = true
    }
    
    func switchToSkills(_ indexPath: IndexPath) {
        self.indexPath = indexPath
        search.resignFirstResponder()
        addSkills.isEnabled = true
        animateCells(indexPath)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "backArrow"), target: self, action: #selector(self.switchToIndustries))
        let pickerItem = dataSource.itemFor(indexPath: indexPath)
        if pickerItem?.children != nil {
            dataSource.pickerItems = Array(pickerItem!.children)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                if self.dataSource.filteredData.count != self.pickerItems!.count {
                    self.enterSearch(false); return
                }
                var delete = [IndexPath]()
                for index in pickerItem!.children.count ..< self.pickerItems!.count {
                    delete.append(IndexPath(row: index, section: 0))
                }
                self.collectionView.deleteItems(at: delete)
                var reload = [IndexPath]()
                for index in 0 ..< pickerItem!.children.count {
                    reload.append(IndexPath(row: index, section: 0))
                }
                self.collectionView.reloadItems(at: reload)
            })
        } else {
            collectionView.reloadSections(IndexSet(integer: 0))
        }
        
        industryMode = false; swap()
        collectionView.allowsMultipleSelection = true
        collectionView.allowsSelection = true
    }
    
    func animateCells(_ indexPath: IndexPath, reverse: Bool = false) {
        let visible = collectionView.indexPathsForVisibleItems
        let row = indexPath.row / 3
        
        for path in visible {
            guard let pickerItem = dataSource.itemFor(indexPath: indexPath) else { return }
            var fadeOut = false
            if path.row >= pickerItem.children.count { fadeOut = !reverse }
            let cell = collectionView.cellForItem(at: path) as! SkillCollectionViewCell
            let cellRow = path.row / 3
            
            if cellRow > row {
                if indexPath.row % 3 == path.row % 3 { cell.animate(direction: .down, row: cellRow - row, reverse: reverse, fadeOut: fadeOut)}
                else if indexPath.row % 3 < path.row % 3 { cell.animate(direction: .leftDown, row: cellRow - row, distance: (path.row % 3) - (indexPath.row % 3), reverse: reverse, fadeOut: fadeOut) }
                else if indexPath.row % 3 > path.row % 3 { cell.animate(direction: .rightDown, row: cellRow - row, distance: (path.row % 3) - (indexPath.row % 3), reverse: reverse, fadeOut: fadeOut) }
            } else if cellRow < row {
                if indexPath.row % 3 == path.row % 3 { cell.animate(direction: .up, row: row - cellRow, reverse: reverse, fadeOut: fadeOut) }
                else if indexPath.row % 3 < path.row % 3 { cell.animate(direction: .leftUp, row: row - cellRow, distance: (indexPath.row % 3) - (path.row % 3), reverse: reverse, fadeOut: fadeOut) }
                else if indexPath.row % 3 > path.row % 3 { cell.animate(direction: .rightUp, row: row - cellRow, distance: (indexPath.row % 3) - (path.row % 3), reverse: reverse, fadeOut: fadeOut) }
            } else if cellRow == row && path != indexPath {
                cell.animate(direction: indexPath.row < path.row ? .left : .right, distance: abs((indexPath.row % 3) - (path.row % 3)), reverse: reverse, fadeOut: fadeOut)
            }
        }
    }
    
    func swap() {
        //enterSearch(false)
    }
    
    func toFeed() {
        collectionView.allowsSelection = false;
        if Token.retrieveLogin().phone_number == nil {
            navigationController?.push(FeedViewController())
        } else {
            LaunchData.fetchLaunchData()
            UIApplication.shared.delegate!.window??.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        }
        if selectedPickerItems.count == 0 { return }
        let request = ProfileRequest(interests: selectedPickerItems.map({ InterestModel(id: "\($0._id)") }))
        Client.execute(request)
    }

}
