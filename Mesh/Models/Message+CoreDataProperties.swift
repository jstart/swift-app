//
//  Message+CoreDataProperties.swift
//  
//
//  Created by Christopher Truman on 9/11/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message");
    }
    
    @NSManaged public var id: String?
    @NSManaged public var ts: Int64
    @NSManaged public var text: String?
    @NSManaged public var recipient: Connection?
    @NSManaged public var sender: Connection?
    
}
