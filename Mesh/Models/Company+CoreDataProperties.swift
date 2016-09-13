//
//  Company+CoreDataProperties.swift
//  
//
//  Created by Christopher Truman on 9/13/16.
//
//

import Foundation
import CoreData


extension Company {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company");
    }

    @NSManaged public var id: String?
    @NSManaged public var start_month: String?
    @NSManaged public var start_year: String?
    @NSManaged public var end_month: String?
    @NSManaged public var end_year: String?
    @NSManaged public var current: Bool
    @NSManaged public var users: User?

}
