//
//  IndustriesCollectionViewDataSource.swift
//  Mesh
//
//  Created by Christopher Truman on 9/13/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class IndustriesCollectionViewDataSource: NSObject, UICollectionViewDataSource, SkillsData {
    
    var searching = false { didSet { if searching == true { filteredData = data } } }
    
    let data = ["Accounting","Airlines/Aviation","Alternative Dispute Resolution","Alternative Medicine","Animation","Apparel & Fashion","Architecture & Planning","Arts and Crafts","Automotive","Aviation & Aerospace","Banking","Biotechnology","Broadcast Media","Building Materials","Business Supplies and Equipment","Capital Markets","Chemicals","Civic & Social Organization","Civil Engineering","Commercial Real Estate","Computer & Network Security","Computer Games","Computer Hardware","Computer Networking","Computer Software","Construction","Consumer Electronics","Consumer Goods","Consumer Services","Cosmetics","Dairy","Defense & Space","Design","Education Management","E-Learning","Electrical/Electronic Manufacturing","Entertainment","Environmental Services","Events Services","Executive Office","Facilities Services","Farming","Financial Services","Fine Art","Fishery","Food & Beverages","Food Production","Fund-Raising","Furniture","Gambling & Casinos","Glass, Ceramics & Concrete","Government Administration","Government Relations","Graphic Design","Health, Wellness and Fitness","Higher Education","Hospital & Health Care","Hospitality","Human Resources","Import and Export","Individual & Family Services","Industrial Automation","Information Services","Information Technology and Services","Insurance","International Affairs","International Trade and Development","Internet","Investment Banking","Investment Management","Judiciary","Law Enforcement","Law Practice","Legal Services","Legislative Office","Leisure, Travel & Tourism","Libraries","Logistics and Supply Chain","Luxury Goods & Jewelry","Machinery","Management Consulting","Maritime","Market Research","Marketing and Advertising","Mechanical or Industrial Engineering","Media Production","Medical Devices","Medical Practice","Mental Health Care","Military","Mining & Metals","Motion Pictures and Film","Museums and Institutions","Music","Nanotechnology","Newspapers","Non-Profit Organization Management","Oil & Energy","Online Media","Outsourcing/Offshoring","Package/Freight Delivery","Packaging and Containers","Paper & Forest Products","Performing Arts","Pharmaceuticals","Philanthropy","Photography","Plastics","Political Organization","Primary/Secondary Education","Printing","Professional Training & Coaching","Program Development","Public Policy","Public Relations and Communications","Public Safety","Publishing","Railroad Manufacture","Ranching","Real Estate","Recreational Facilities and Services","Religious Institutions","Renewables & Environment","Research","Restaurants","Retail","Security and Investigations","Semiconductors","Shipbuilding","Sporting Goods","Sports","Staffing and Recruiting","Supermarkets","Telecommunications","Textiles","Think Tanks","Tobacco","Translation and Localization","Transportation/Trucking/Railroad","Utilities","Venture Capital & Private Equity","Veterinary","Warehousing","Wholesale","Wine and Spirits","Wireless","Writing and Editing"]
    
    var filteredData : [String]?
    
    convenience init(_ collectionView: UICollectionView) {
        self.init()
        collectionView.registerClass(SkillCollectionViewCell.self)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func filter(_ text: String) {
        if text == "" { filteredData = data; return}
        filteredData = data.filter({$0.localizedCaseInsensitiveContains(text)})
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if filteredData == nil { return data.count }
        if filteredData?.count == 0 { return 1 }
        return filteredData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(SkillCollectionViewCell.self, indexPath: indexPath).then {
            let even : Bool = (indexPath.row % 2) == 0

            if filteredData != nil {
                if filteredData!.count == 0 {
                    $0.configure("Add", image: #imageLiteral(resourceName: "addCard"), searching: searching); return
                }else {
                    $0.configure(filteredData![indexPath.row], image: even ? #imageLiteral(resourceName: "tech") : #imageLiteral(resourceName: "business"), searching: searching); return
                }
            }
            $0.configure(data[indexPath.row], image: even ? #imageLiteral(resourceName: "tech") : #imageLiteral(resourceName: "business"), searching: searching)
        }
    }
    
}
