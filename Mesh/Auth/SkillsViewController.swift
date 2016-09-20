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
            $0.allowsMultipleSelection = true
            $0.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)

        if Token.retrieveToken() == nil { Client.execute(TokenRequest(), completionHandler: { _ in }) }
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
            collectionView.reloadSections(IndexSet(integer: 0))
            dataSource.searching = false
            navigationItem.setRightBarButtonItems([UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(openSearch))], animated: true)
            navigationItem.titleView = nil
            search.resignFirstResponder()
        } else {
            navigationItem.setRightBarButton(nil, animated: true)
            dataSource.searching = true
            navigationItem.titleView = search
            search.becomeFirstResponder()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.scaleIn(delay: 0.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)!.squeezeIn()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)!.squeezeOut()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.squeezeInOut() { _ in
            if self.dataSource is SkillsCollectionViewDataSource {
                if collectionView.indexPathsForSelectedItems!.count > 2 { self.toFeed() }
            } else {
                self.switchToSkills()
            }
        }
    }
    
    func switchToIndustries() {
        collectionView.fadeOut(duration: 0.35) {
            self.enterSearch(false)
            self.navigationItem.backBarButtonItem = nil
            self.dataSource = IndustriesCollectionViewDataSource(self.collectionView)
            self.title = "Select Industries"
            self.collectionView.dataSource = self.dataSource
            self.collectionView.reloadSections(IndexSet(integer: 0))
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "backArrow"), target: self.navigationController!, action: #selector(UINavigationController.popViewController(animated:)))
            self.collectionView.fadeIn(duration: 0.35)
        }
    }
    
    func switchToSkills() {
        collectionView.fadeOut(duration: 0.35) {
            self.enterSearch(false)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "backArrow"), target: self, action: #selector(self.switchToIndustries))
            self.dataSource = SkillsCollectionViewDataSource(self.collectionView)
            self.title = "Select Skills"
            self.collectionView.dataSource = self.dataSource
            self.collectionView.reloadSections(IndexSet(integer: 0))
            self.collectionView.fadeIn(duration: 0.35)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.squeezeInOut()
    }
    
    func toFeed() { navigationController?.push(FeedViewController()) }

}
