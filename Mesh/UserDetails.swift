//
//  UserDetails.swift
//  Mesh
//
//  Created by Christopher Truman on 8/15/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation

protocol UserDetail {
    var hasButton : Bool { get }
    var hasDate : Bool { get }
    static var category : QuickViewCategory { get }
}

extension UserDetail {
    var hasButton : Bool { return false }
    var hasDate : Bool { return false }
}

struct Connection : UserDetail {
    var name : String
    var position : String
    var isConnected : Bool
    
    static var category = QuickViewCategory.connections
}

struct Experience : UserDetail {
    var company : String
    var position : String
    var startYear : String
    var endYear : String
    
    static var category = QuickViewCategory.experience
}

struct Education : UserDetail {
    var schoolImage : String
    var schoolName : String
    var degreeType : String
    var startYear : String
    var endYear : String
    
    static var category = QuickViewCategory.education
}

struct Skill : UserDetail {
    var name : String
    var numberOfMembers : String
    var isAdded : Bool
    
    static var category = QuickViewCategory.skills
}

struct Event : UserDetail {
    var name : String
    var date : String
    var isGoing : Bool
    
    static var category = QuickViewCategory.events
}

struct UserDetails {
    var connections : [Connection]
    var experiences : [Experience]
    var educationItems : [Education]
    var skills : [Skill]
    var events : [Event]
}
