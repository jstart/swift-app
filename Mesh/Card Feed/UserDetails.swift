//
//  UserDetails.swift
//  Mesh
//
//  Created by Christopher Truman on 8/15/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation

enum FieldType { case text, month, year, toggle }

typealias EditField = (placeholder: String, type: FieldType)

protocol UserDetail {
    var hasButton : Bool { get }
    var hasDate : Bool { get }
    
    var firstText : String { get }
    var secondText : String { get }
    var thirdText : String { get }
    
    var fields : [EditField] { get }

    var category : QuickViewCategory { get }
}

extension UserDetail {
    var hasButton : Bool { return false }
    var hasDate : Bool { return false }
    
    var firstText : String { return "" }
    var secondText : String { return "" }
    var thirdText : String { return "" }
    
    var fields : [EditField] { return [] }
}

struct ConnectionResponses : UserDetail {
    var name : String
    var position : String
    var isConnected : Bool
    
    let category = QuickViewCategory.connections
}

struct Experience : UserDetail {
    var company : String
    var position : String
    var startYear : String
    var endYear : String
    var hasDate : Bool { return true }
    
    var firstText : String { return company }
    var secondText : String { return position }
    var thirdText : String { return startYear + " - " + endYear } //TODO: Current
    
    var fields : [EditField] { return [("Company Name", .text), ("Job Title", .text), ("From", .month), ("To", .month), ("I currently work here", .toggle)] }
    
    let category = QuickViewCategory.experience
}

struct Education : UserDetail {
    var schoolName : String
    var degreeType : String
    var startYear : String
    var endYear : String
    var hasDate : Bool { return true }
    
    var firstText : String { return schoolName }
    var secondText : String { return degreeType }
    var thirdText : String { return startYear + " - " + endYear } //TODO: Current

    var fields : [EditField] { return [("School", .text), ("Start Year", .year), ("End Year", .year), ("Graduated", .toggle), ("Degree", .text), ("Field of Study", .text)] }

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
    
    let category = QuickViewCategory.events
}

struct UserDetails {
    var connections : [ConnectionResponses]
    var experiences : [Experience]
    var educationItems : [Education]
    var skills : [Skill]
    var events : [Event]
}
