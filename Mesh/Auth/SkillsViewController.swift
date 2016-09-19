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
    
    lazy var dataSource : SkillsCollectionViewDataSource = { return SkillsCollectionViewDataSource(self.collectionView) }()
    let search = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Select Skills"
        
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        collectionView.constrain(.centerX, .centerY, .width, .height, toItem: view)
        collectionView.reloadData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(openSearch))
        search.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" || searchText == "" {
            dataSource.count = 30
            collectionView.reloadSections(IndexSet(integer: 0))
            return
        }
        dataSource.count -= 1
        if dataSource.count >= 0 {
            collectionView.deleteItems(at: [IndexPath(item: dataSource.count, section: 0)])
        }else {
            dataSource.count = 0
        }
    }
    
    func openSearch() {
        if dataSource.searching {
            search.text = ""
            dataSource.count = 30
            collectionView.reloadSections(IndexSet(integer: 0))
            dataSource.searching = false
            navigationItem.rightBarButtonItem?.title = "Search"
            navigationItem.titleView = nil
            search.resignFirstResponder()
        } else {
            dataSource.searching = true
            navigationItem.rightBarButtonItem?.title = "Cancel"
            navigationItem.titleView = search
            search.becomeFirstResponder()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotation.duration = 0.2
        rotation.fromValue = 0
        rotation.toValue = 0.1 * CGFloat(M_PI)
        rotation.repeatCount = 1
        rotation.autoreverses = true
        collectionView.cellForItem(at: indexPath)?.layer.add(rotation, forKey: rotation.keyPath)
        
        if collectionView.indexPathsForSelectedItems!.count > 2 { toFeed() }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotation.duration = 0.2
        rotation.fromValue = 0
        rotation.toValue = -(0.1 * CGFloat(M_PI))
        rotation.repeatCount = 1
        rotation.autoreverses = true
        collectionView.cellForItem(at: indexPath)?.layer.add(rotation, forKey: rotation.keyPath)
    }
    
    func toFeed() { navigationController?.push(FeedViewController()) }

}
