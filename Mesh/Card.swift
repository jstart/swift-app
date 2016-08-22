//
//  Card.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation

enum CardType : String {
    case person = "Person"
    case skill = "Skill"
    case event = "Event"
}

struct Company {
    var name : String = ""
    var imageURL : URL?
}

struct Person {
    var user : UserResponse?
    var details : UserDetails
}

struct Card {
    var type : CardType
    var person : Person?
}
