//
//  IndustriesCollectionViewDataSource.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class IndustriesCollectionViewDataSource: NSObject, UICollectionViewDataSource, SkillsData {
    
    var searching = false { didSet { if searching == true { filteredData = pickerItems } } }

    var pickerItems = [PickerResponse]()
    var filteredData = [PickerResponse]()
    
    convenience init(_ collectionView: UICollectionView) {
        self.init()
        collectionView.registerClass(SkillCollectionViewCell.self)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func filter(_ text: String) {
        if text == "" { filteredData = pickerItems; return}
        filteredData = pickerItems.filter({$0.name!.localizedCaseInsensitiveContains(text)})
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !searching { return pickerItems.count }
        if filteredData.count == 0 { return 1 }
        return filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(SkillCollectionViewCell.self, indexPath: indexPath).then {
            if searching {
                if filteredData.count == 0 {
                    $0.configure("Add", image: #imageLiteral(resourceName: "addCard"), searching: searching); return
                } else {
                    $0.configure(filteredData[indexPath.row], searching: searching); return
                }
            }
            $0.configure(pickerItems[indexPath.row], searching: searching)
        }
    }
    
}
