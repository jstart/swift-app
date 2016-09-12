//
//  Connection+CoreDataProperties.swift
//
//
//  Created by Christopher Truman on 9/11/16.
//
//

import Foundation
import CoreData

extension Connection {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Connection> {
        return NSFetchRequest<Connection>(entityName: "Connection");
    }
    
    @NSManaged public var id: String
    @NSManaged public var muted: Bool
    @NSManaged public var read: Bool
    @NSManaged public var update_date: NSDate
    @NSManaged public var recipient: Message?
    @NSManaged public var sender: Message?
    @NSManaged public var user: User
    
}
