//
//  Message+CoreDataClass.swift
//  
//
//  Created by Christopher Truman on 9/11/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(Message)
public class Message: NSManagedObject {
    convenience init(JSON: JSONDictionary) {
        self.init(entity: NSEntityDescription.entity(forEntityName: "Message", in: CoreData.backgroundContext)!, insertInto: CoreData.backgroundContext)

        id = JSON["_id"] as? String
        ts = (JSON["ts"] as! NSNumber).int64Value
//        sender = JSON["sender"] as! String
//        recipient = JSON["recipient"] as! String
        text = (JSON["text"] as? String) ?? ""
        CoreData.backgroundContext.insert(self)
    }
}
