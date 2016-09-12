//
//  User+CoreDataProperties.swift
//  
//
//  Created by Christopher Truman on 9/11/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var email: String?
    @NSManaged public var first_name: String?
    @NSManaged public var id: String?
    @NSManaged public var last_name: String?
    @NSManaged public var phone_number: String?
    @NSManaged public var profession: String?
    @NSManaged public var title: String?
    @NSManaged public var connection: Connection?

}
