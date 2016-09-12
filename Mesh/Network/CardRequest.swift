//
//  CardRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 9/3/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

struct CardsRequest : AuthenticatedRequest {
    let path = "card", method = HTTPMethod.get
}

struct CardResponse {
    static var cards = [Card]()
}

struct CardCreateRequest : AuthenticatedRequest {
    let path = "card", method = HTTPMethod.put
    
    let position : Int,
        first_name : Bool,
        last_name : Bool,
        email : Bool,
        phone_number : Bool,
        title : Bool

    func parameters() -> [String : Any] {
        return ["fields" :["first_name" : first_name, "last_name" : last_name, "email" : email, "phone_number" : phone_number, "title" : title], "position" : position]
    }
    
    static func new() -> CardCreateRequest {
        return CardCreateRequest(position: CardResponse.cards.count , first_name: true, last_name: true, email: false, phone_number: true, title: false)
    }
}

struct CardEditRequest : AuthenticatedRequest {
    let path = "card", method = HTTPMethod.post
    
    let _id : String,
        first_name : Bool,
        last_name : Bool,
        email : Bool,
        phone_number : Bool,
        title : Bool
    
    func parameters() -> [String : Any] {
        return ["_id": _id, "fields" :["first_name" : first_name, "last_name" : last_name, "email" : email, "phone_number" : phone_number, "title" : title]]
    }
}

struct CardDeleteRequest : AuthenticatedRequest {
    let path = "card", method = HTTPMethod.delete
    
    let _id : String
    
    func parameters() -> [String : Any] {
        return ["_id": _id]
    }
}

struct CardSyncRequest : AuthenticatedRequest {
    let path = "card/sync", method = HTTPMethod.put
    
    let _id : String,
    my_token : String,
    scanned_token : String
    
    func parameters() -> [String : Any] {
        return ["_id": _id, "my_token": my_token, "scanned_token": scanned_token]
    }
}
