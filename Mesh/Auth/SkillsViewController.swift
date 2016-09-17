//
//  SkillsViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SkillsViewController: UIViewController, UICollectionViewDelegate {
    let layout = UICollectionViewFlowLayout().then { $0.estimatedItemSize = CGSize(width: 100, height: 100) }
    
    lazy var collectionView : UICollectionView = {
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout).then {
            $0.translates = false
            $0.backgroundColor = .white
            $0.allowsMultipleSelection = true
            $0.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }()
    
    lazy var dataSource : SkillsCollectionViewDataSource = { return SkillsCollectionViewDataSource(self.collectionView) }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Select Skills"
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        collectionView.constrain(.centerX, .centerY, .width, .height, toItem: view)
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
    
    func toFeed() { navigationController?.push(FeedViewController())
    }
}
