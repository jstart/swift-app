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
    static var cards : [CardResponse]?
    let token : String,
        _id : String,
        first_name : Bool,
        last_name : Bool,
        email : Bool,
        phone_number : Bool,
        title : Bool
    
    init(JSON: [String : Any]) {
        token = (JSON["token"] as? String) ?? ""
        _id = JSON["_id"] as! String
        let fields = JSON["fields"] as! JSONDictionary
        first_name = (fields["first_name"] as? Bool) ?? false
        last_name = (fields["last_name"] as? Bool) ?? false
        email = (fields["email"] as? Bool) ?? false
        phone_number = (fields["phone_number"] as? Bool) ?? false
        title = (fields["title"] as? Bool) ?? false
    }
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
        return ["first_name" : first_name, "last_name" : last_name, "email" : email, "phone_number" : phone_number, "title" : title, "position" : position]
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
        return ["_id": _id, "first_name" : first_name, "last_name" : last_name, "email" : email, "phone_number" : phone_number, "title" : title]
    }
}
