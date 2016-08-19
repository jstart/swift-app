//
//  AuthRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

struct AuthRequest : Request {
    let path = "auth"
    let method = HTTPMethod.post
    
    var phone_number : String
    var password : String
    var password_verify : String
    var first_name : String
    var last_name : String
    var email : String
    var company : String
    var profession : String
    
    func parameters() -> [String : AnyObject] {
        return ["phone_number": phone_number, "password" : password, "password_verify" : password_verify, "first_name" : first_name, "last_name" : last_name, "email" : email, "company" : company, "profession" : profession]
    }
}

struct TokenRequest : Request {
    let path = "token"
    let method = HTTPMethod.get
}

struct LoginRequest : Request {
    let path = "login"
    let method = HTTPMethod.post
    
    var phone_number : String
    var password : String
    
    func parameters() -> [String : AnyObject] {
        return ["phone_number": phone_number, "password" : password]
    }
}

struct UserResponse {
    var _id : String
    var phone_number : String
    //var first_name : String
    //var last_name : String
    //var company : String
    //var profession : String
    var token : String
    
    init(JSON: [String : AnyObject]) {
        _id = JSON["_id"] as! String
        phone_number = JSON["phone_number"] as! String
        //first_name = JSON["first_name"] as String?
        //last_name = JSON["last_name"] as String?
        //company = JSON["company"] as String?
        //profession = JSON["profession"] as String?
        token = JSON["token"] as! String
    }
}

struct LogoutRequest : Request {
    let path = "logout"
    let method = HTTPMethod.post
}
