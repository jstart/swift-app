//
//  Connection+CoreDataClass.swift
//
//
//  Created by Christopher Truman on 9/11/16.
//
//

import Foundation
import CoreData

@objc(Connection)
public class Connection: NSManagedObject {
    convenience init(JSON: JSONDictionary) {
        self.init(entity: NSEntityDescription.entity(forEntityName: "Connection", in: CoreData.backgroundContext)!, insertInto: CoreData.backgroundContext)
        id = JSON["_id"] as! String
        user = User(JSON: JSON)
        read = JSON["read"] as? Bool ?? true
        muted = JSON["read"] as? Bool ?? false
        let date = (JSON["update_date"] as? Int) ?? 0
        update_date = NSDate(timeIntervalSince1970: TimeInterval(date/1000))
        
        CoreData.backgroundContext.insert(self)
    }
}
