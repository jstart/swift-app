//
//  Card.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation

enum CardType : String {
    case Person = "Person"
}

struct Company {
    var name : String = ""
    var imageURL : URL?
}

struct Person {
    var firstName : String = ""
    var lastName : String = ""
    var company : Company?
}

struct Card {
    var type : CardType
    var person : Person?
}
