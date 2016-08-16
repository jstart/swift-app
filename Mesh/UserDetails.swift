//
//  UserDetails.swift
//  Mesh
//
//  Created by Christopher Truman on 8/15/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation

struct Connection {
    var name : String
    var position : String
    var isConnected : Bool
}

struct Experience {
    var company : String
    var position : String
    var startYear : String
    var endYear : String
}

struct Education {
    var schoolImage : String
    var schoolName : String
    var degreeType : String
    var startYear : String
    var endYear : String
}

struct Skill {
    var name : String
    var numberOfMembers : String
    var isAdded : Bool
}

struct Event {
    var name : String
    var date : String
    var isGoing : Bool
}

struct UserDetails {
    var connections : [Connection]
    var experiences : [Experience]
    var educationItems : [Education]
    var skills : [Skill]
    var events : [Event]
}
