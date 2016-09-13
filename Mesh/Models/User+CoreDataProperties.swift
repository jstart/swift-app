//
//  User+CoreDataProperties.swift
//
//
//  Created by Christopher Truman on 9/13/16.
//
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
    @NSManaged public var companies: NSOrderedSet?
    
}

// MARK: Generated accessors for companies
extension User {
    
    @objc(insertObject:inCompaniesAtIndex:)
    @NSManaged public func insertIntoCompanies(_ value: Company, at idx: Int)
    
    @objc(removeObjectFromCompaniesAtIndex:)
    @NSManaged public func removeFromCompanies(at idx: Int)
    
    @objc(insertCompanies:atIndexes:)
    @NSManaged public func insertIntoCompanies(_ values: [Company], at indexes: NSIndexSet)
    
    @objc(removeCompaniesAtIndexes:)
    @NSManaged public func removeFromCompanies(at indexes: NSIndexSet)
    
    @objc(replaceObjectInCompaniesAtIndex:withObject:)
    @NSManaged public func replaceCompanies(at idx: Int, with value: Company)
    
    @objc(replaceCompaniesAtIndexes:withCompanies:)
    @NSManaged public func replaceCompanies(at indexes: NSIndexSet, with values: [Company])
    
    @objc(addCompaniesObject:)
    @NSManaged public func addToCompanies(_ value: Company)
    
    @objc(removeCompaniesObject:)
    @NSManaged public func removeFromCompanies(_ value: Company)
    
    @objc(addCompanies:)
    @NSManaged public func addToCompanies(_ values: NSOrderedSet)
    
    @objc(removeCompanies:)
    @NSManaged public func removeFromCompanies(_ values: NSOrderedSet)
    
}
