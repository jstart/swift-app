//
//  Card+CoreDataClass.swift
//  
//
//  Created by Christopher Truman on 9/11/16.
//
//

import Foundation
import CoreData

public class Card: NSManagedObject {

    convenience init(JSON: JSONDictionary) {
        self.init(entity: NSEntityDescription.entity(forEntityName: "Card", in: CoreData.backgroundContext)!, insertInto: CoreData.backgroundContext)
        token = (JSON["token"] as? String) ?? ""
        id = (JSON["_id"] as? String) ?? ""
        let fields = JSON["fields"] as! JSONDictionary
        first_name = (fields["first_name"] as? NSNumber) ?? false
        last_name = (fields["last_name"] as? NSNumber) ?? false
        email = (fields["email"] as? NSNumber) ?? false
        phone_number = (fields["phone_number"] as? NSNumber) ?? false
        title = (fields["title"] as? NSNumber) ?? false
    }
    
}
