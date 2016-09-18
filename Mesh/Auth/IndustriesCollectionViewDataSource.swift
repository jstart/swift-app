//
//  IndustriesCollectionViewDataSource.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class IndustriesCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var count = 10
    var searching = false
    
    convenience init(_ collectionView: UICollectionView) {
        self.init()
        collectionView.registerClass(SkillCollectionViewCell.self)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(SkillCollectionViewCell.self, indexPath: indexPath).then {
            $0.configure("Test", image: #imageLiteral(resourceName: "tesla"), searching: searching)
        }
    }
}
