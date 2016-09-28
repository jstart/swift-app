//
//  User+CoreDataClass.swift
//  
//
//  Created by Christopher Truman on 9/11/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    convenience init(JSON: JSONDictionary) {
        self.init(entity: NSEntityDescription.entity(forEntityName: "User", in: CoreData.backgroundContext)!, insertInto: CoreData.backgroundContext)
        
        id = (JSON["_id"] as? String) ?? ""
        id = (JSON["user_id"] as? String?)! ?? id
        phone_number = (JSON["phone_number"] as? String?)!
        email = (JSON["email"] as? String?)!
        first_name = (JSON["first_name"] as? String?)!
        last_name = (JSON["last_name"] as? String?)!
        title = (JSON["title"] as? String?)!
        //        if let companiesJSON = JSON["companies"] as? JSONArray{
        //            companies = companiesJSON.map({return CompanyModel.create(JSON: $0)})
        //        }
        profession = (JSON["profession"] as? String?)!
        //        if JSON["profile_photo"] != nil{
        //            photos = PhotoResponse(JSON:(JSON["profile_photo"] as! JSONDictionary))
        //        }
        //        if JSON["position"] != nil{
        //            position = PositionResponse(JSON:(JSON["position"] as! JSONDictionary))
        //        }
        CoreData.backgroundContext.insert(self)
    }
    
    func fullName() -> String {
        return (first_name ?? "") + " " + (last_name ?? "")
    }
    
    func fullTitle() -> String {
//        guard let company = companies?.first else { return title ?? "" }
        return (title ?? "") //+ " at " + company.id
    }
//
//    func searchText() -> String {
//        let companyNames = companies?.map({return $0.id}).joined(separator: " ")
//        return fullName() + (title ?? "") + (companyNames ?? "") // profession?
//    }
}
