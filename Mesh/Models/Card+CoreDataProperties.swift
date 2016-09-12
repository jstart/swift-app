//
//  Card+CoreDataProperties.swift
//  
//
//  Created by Christopher Truman on 9/11/16.
//
//

import Foundation
import CoreData

extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card");
    }

    @NSManaged public var id: String
    @NSManaged public var token: String
    @NSManaged public var first_name: NSNumber 
    @NSManaged public var last_name: NSNumber
    @NSManaged public var email: NSNumber
    @NSManaged public var phone_number: NSNumber
    @NSManaged public var title: NSNumber

}
