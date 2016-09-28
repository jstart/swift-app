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
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.constrain((.height, 50))
    }
    
    let completeView = UIView(translates: false).then {
        $0.backgroundColor = .white
        $0.layer.shadowColor = UIColor.lightGray.cgColor
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 5
    }
    
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

        if Token.retrieveToken() == nil { Client.execute(TokenRequest()) }
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { cell.scaleIn(delay: 0.5) }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) { collectionView.cellForItem(at: indexPath)!.squeezeIn() }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) { collectionView.cellForItem(at: indexPath)!.squeezeOut() }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.squeezeInOut() { _ in
            if self.dataSource is IndustriesCollectionViewDataSource { self.switchToSkills() }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) { collectionView.cellForItem(at: indexPath)?.squeezeInOut() }
    
    func switchToIndustries() {
        addSkills.isEnabled = false
        collectionView.allowsSelection = false
        collectionView.fadeOut(duration: 0.35) {
            self.navigationItem.backBarButtonItem = nil
            self.dataSource = IndustriesCollectionViewDataSource(self.collectionView)
            self.title = "Select Industries"; self.swap()
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "backArrow"), target: self.navigationController!, action: #selector(UINavigationController.popViewController(animated:)))
            self.collectionView.allowsSelection = true
        }
    }
    
    func switchToSkills() {
        addSkills.isEnabled = true
        collectionView.allowsSelection = false
        collectionView.fadeOut(duration: 0.35) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "backArrow"), target: self, action: #selector(self.switchToIndustries))
            self.dataSource = SkillsCollectionViewDataSource(self.collectionView)
            self.title = "Select Skills"; self.swap()
            self.collectionView.allowsMultipleSelection = true
        }
    }
    
    func swap() {
        self.enterSearch(false)
        self.collectionView.dataSource = self.dataSource
        self.collectionView.reloadSections(IndexSet(integer: 0))
        self.collectionView.fadeIn(duration: 0.35)
    }
    
    func toFeed() { collectionView.allowsSelection = false; navigationController?.push(FeedViewController()) }

}
