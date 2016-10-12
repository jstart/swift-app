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
            $0.translates = false
            $0.backgroundColor = .white
            $0.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }()
    let complete = UIButton(translates: false).then {
        $0.setBackgroundImage(.imageWithColor(Colors.brand), for: .normal)
        $0.setBackgroundImage(.imageWithColor(.lightGray), for: .disabled)
        $0.isEnabled = true
        $0.titleLabel?.font = .boldProxima(ofSize: 20); $0.titleColor = .white
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.title = "COMPLETE"
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.constrain((.height, 50))
    }
    let addSkills = UIButton(translates: false).then {
        $0.isEnabled = false
        $0.setBackgroundImage(.imageWithColor(.lightGray), for: .normal)
        $0.titleLabel?.font = .boldProxima(ofSize: 20); $0.titleColor = .white
        $0.setTitle("ADD MORE SKILLS", for: .normal)
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.layer.cornerRadius = 5
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        $0.clipsToBounds = true
        $0.constrain((.height, 50))
    }
    let completeView = UIView(translates: false).then {
        $0.backgroundColor = .white
        $0.layer.shadowColor = UIColor.lightGray.cgColor
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 5
    }
    var indexPath : IndexPath?
    
    lazy var dataSource : SkillsData = { return IndustriesCollectionViewDataSource(self.collectionView) }()
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(openSearch))
        search.delegate = self
        search.showsCancelButton = true
        
        Token.deleteToken()
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)

        if Token.retrieveToken() == nil { Client.execute(TokenRequest()) { _ in
                Client.execute(PickerRequest()) { response in
                    print(response.result.value)
                }
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
            navigationItem.setRightBarButtonItems([UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(openSearch))], animated: true)
            navigationItem.titleView = nil
        } else {
            navigationItem.setRightBarButton(nil, animated: true)
            dataSource.searching = true
            navigationItem.titleView = search
            search.becomeFirstResponder()
        }
    }
    
    //func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { cell.scaleIn(delay: 0.5) }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) { collectionView.cellForItem(at: indexPath)!.squeezeIn() }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) { collectionView.cellForItem(at: indexPath)!.squeezeOut() }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.dataSource is IndustriesCollectionViewDataSource { self.switchToSkills(indexPath) }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) { collectionView.cellForItem(at: indexPath)?.squeezeInOut() }
    
    func switchToIndustries() {
        search.resignFirstResponder()

        addSkills.isEnabled = false
        collectionView.allowsSelection = false
        navigationItem.backBarButtonItem = nil
        animateCells(self.indexPath!, reverse: true)
        //dataSource = IndustriesCollectionViewDataSource(self.collectionView)
        title = "Select Industry"; swap()
        navigationItem.leftBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "backArrow"), target: navigationController!, action: #selector(UINavigationController.popViewController(animated:)))
        collectionView.allowsSelection = true
    }
    
    func switchToSkills(_ indexPath: IndexPath) {
        self.indexPath = indexPath
        search.resignFirstResponder()
        addSkills.isEnabled = true
        collectionView.allowsSelection = false
        animateCells(indexPath)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "backArrow"), target: self, action: #selector(self.switchToIndustries))
        //dataSource = SkillsCollectionViewDataSource(collectionView)
        title = "Select Skills"; swap()
        collectionView.allowsMultipleSelection = true
    }
    
    func animateCells(_ indexPath: IndexPath, reverse: Bool = false) {
        let visible = collectionView.indexPathsForVisibleItems
        let row = indexPath.row/3
        
        for path in visible {
            let cell = collectionView.cellForItem(at: path) as! SkillCollectionViewCell
            let cellRow = path.row/3
            
            if cellRow > row {
                if indexPath.row % 3 == path.row % 3 { cell.animate(direction: .down, row: cellRow - row, reverse: reverse)}
                else if indexPath.row % 3 < path.row % 3 { cell.animate(direction: .leftDown, row: cellRow - row, reverse: reverse) }
                else if indexPath.row % 3 > path.row % 3 { cell.animate(direction: .rightDown, row: cellRow - row, reverse: reverse) }
            } else if cellRow < row {
                if indexPath.row % 3 == path.row % 3 { cell.animate(direction: .up, row: row - cellRow, reverse: reverse) }
                else if indexPath.row % 3 < path.row % 3 { cell.animate(direction: .leftUp, row: row - cellRow, reverse: reverse) }
                else if indexPath.row % 3 > path.row % 3 { cell.animate(direction: .rightUp, row: row - cellRow, reverse: reverse) }
            } else if cellRow == row && path != indexPath {
                cell.animate(direction: indexPath.row < path.row ? .left : .right, reverse: reverse)
            }
        }
    }
    
    func swap() {
        //enterSearch(false)
        //collectionView.dataSource = dataSource
        //collectionView.reloadData()
    }
    
    func toFeed() { collectionView.allowsSelection = false; navigationController?.push(FeedViewController()) }

}
