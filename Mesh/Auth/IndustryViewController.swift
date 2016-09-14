//
//  IndustryViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class IndustryViewController: UIViewController {
    let layout = UICollectionViewFlowLayout().then {
        $0.estimatedItemSize = CGSize(width: 100, height: 100)
    }
    
    lazy var collectionView : UICollectionView = {
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout).then {
            $0.translates = false
            $0.backgroundColor = .white
        }
    }()
    
    lazy var dataSource : SkillsCollectionViewDataSource = {
        return SkillsCollectionViewDataSource(self.collectionView)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        title = "Select Industry"
        
        collectionView.collectionViewLayout = layout
        
        collectionView.dataSource = dataSource
        
        view.addSubview(collectionView)
        
        collectionView.constrain(.centerX, .centerY, .width, .height, toItem: view)
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
