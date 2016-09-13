//
//  Card.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation

enum CardType : String {
    case person = "Person", tweet = "Tweet", skill = "Skill", event = "Event"
}

struct Person {
    var user : UserResponse?
    var details : UserDetails
}

struct Rec {
    var type : CardType
    var person : Person?
}
