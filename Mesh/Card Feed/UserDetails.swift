//
//  UserDetails.swift
//  Mesh
//
//  Created by Christopher Truman on 8/15/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import RealmSwift

enum FieldType { case text, autocomplete, month, year, toggle }

typealias EditField = (placeholder: String, type: FieldType)

protocol UserDetail {
    var hasButton : Bool { get }
    var hasDate : Bool { get }
    
    var logo : String? { get }
    var firstText : String { get }
    var secondText : String { get }
    var thirdText : String { get }
    
    static var fields : [EditField] { get }
    func fieldValues() -> [Any]

    var category : QuickViewCategory { get }
}

extension UserDetail {
    var hasButton : Bool { return false }
    var hasDate : Bool { return false }
    
    var logo : String? { return nil }
    var firstText : String { return "" }
    var secondText : String { return "" }
    var thirdText : String { return "" }
    
    static var fields : [EditField] { return [] }
    func fieldValues() -> [Any] { return [Any]() }
}

struct ConnectionDetail : UserDetail {
    var name : String
    var position : String
    var isConnected : Bool
    
    let category = QuickViewCategory.connections
}

struct Experience : UserDetail {
    var company : String
    var position : String
    var startMonth : String
    var startYear : String
    var endMonth : String
    var endYear : String
    var hasDate : Bool { return true }
    
    var firstText : String { return company }
    var secondText : String { return position }
    var thirdText : String { return startYear + " - " + endYear } //TODO: Current
    
    static var fields : [EditField] { return [("Company Name", .text), ("Job Title", .text), ("From", .month), ("To", .month), ("I currently work here", .toggle)] }
    
    func fieldValues() -> [Any] {
        return [company, position, [startMonth, startYear], [endMonth, endYear], true]
    }
    
    let category = QuickViewCategory.experience
}

struct Education : UserDetail {
    var schoolName : String
    var degreeType : String
    var startYear : String
    var endYear : String
    var field : String
    var graduated : Bool

    var hasDate : Bool { return true }
    
    var firstText : String { return schoolName }
    var secondText : String { return degreeType }
    var thirdText : String { return startYear + " - " + endYear } //TODO: Current

    static var fields : [EditField] { return [("School", .text), ("Start Year", .year), ("End Year", .year), ("Graduated", .toggle), ("Degree", .text), ("Field of Study", .text)] }
    func fieldValues() -> [Any] {
        return [schoolName, startYear, endYear, true, degreeType, field]
    }
    let category = QuickViewCategory.education
}

struct Skill : UserDetail {
    var name : String
    var numberOfMembers : String
    var isAdded : Bool
    
    var firstText : String { return name }
    var secondText : String { return numberOfMembers }
    
    let category = QuickViewCategory.skills
}

struct Event : UserDetail {
    var name : String
    var date : String
    var isGoing : Bool
    
    var firstText : String { return name }
    var secondText : String { return date }
    
    let category = QuickViewCategory.events
}

struct UserDetails {
    var connections : [ConnectionDetail]
    var experiences : [CompanyResponse]
    var educationItems : [SchoolResponse]
    var skills : [InterestResponse]
    var events : [Event]
    
    func details(forIndex: Int) -> [UserDetail]? {
        switch forIndex {
        case 0: return connections
        case 1: return experiences
        case 2: return educationItems
        case 3: return skills
        case 4: return events
        default: return nil }
    }
}
