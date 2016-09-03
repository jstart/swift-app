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
    let token : String,
        _id : String,
        first_name : Bool,
        last_name : Bool,
        email : Bool,
        phone_number : Bool,
        title : Bool
    
    init(JSON: [String : Any]) {
        token = JSON["token"] as! String
        _id = JSON["_id"] as! String
        first_name = (JSON["first_name"] as? Bool) ?? false
        last_name = (JSON["last_name"] as? Bool) ?? false
        email = (JSON["email"] as? Bool) ?? false
        phone_number = (JSON["phone_number"] as? Bool) ?? false
        title = (JSON["title"] as? Bool) ?? false
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
    
    let first_name : Bool,
        last_name : Bool,
        email : Bool,
        phone_number : Bool,
        title : Bool
    
    func parameters() -> [String : Any] {
        return ["first_name" : first_name, "last_name" : last_name, "email" : email, "phone_number" : phone_number, "title" : title]
    }
}
