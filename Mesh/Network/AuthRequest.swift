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
    
    func parameters() -> [String : Any] {
        return ["phone_number": phone_number, "password" : password, "password_verify" : password_verify]
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
    
    func parameters() -> [String : Any] {
        return ["phone_number": phone_number, "password" : password]
    }
}

struct UserResponse {
    static var currentUser : UserResponse?
    var _id : String
    var phone_number : String
    var first_name : String?
    var last_name : String?
    var companies : [CompanyModel]?
    var profession : String?
    var title : String?
    var photos : PhotoResponse?
    var position : PositionResponse?
    var token : String?
    
    init(JSON: [String : Any]) {
        _id = JSON["_id"] as! String
        phone_number = JSON["phone_number"] as! String
        first_name = (JSON["first_name"] as? String?)!
        last_name = (JSON["last_name"] as? String?)!
        title = (JSON["title"] as? String?)!
        //TODO: companies = (JSON["company"] as? String?)!
        profession = (JSON["profession"] as? String?)!
        token = (JSON["token"] as? String?)!
        if JSON["profile_photo"] != nil{
            photos = PhotoResponse(JSON:(JSON["profile_photo"] as! [String : Any]))
        }
        if JSON["position"] != nil{
            position = PositionResponse(JSON:(JSON["position"] as! [String : Any]))
        }
    }
}

struct PhotoResponse {
    var small : String?
    var medium : String?
    var large : String?
    
    init(JSON: [String : Any]) {
        small = (JSON["small"] as? String?)!
        medium = (JSON["medium"] as? String?)!
        large = (JSON["large"] as? String?)!
    }
}

struct PositionResponse {
    var lat : Double?
    var lon : Double?
    
    init(JSON: [String : Any]) {
        lat = (JSON["lat"] as? Double?)!
        lon = (JSON["lon"] as? Double?)!
    }
}

struct LogoutRequest : AuthenticatedRequest {
    let path = "logout"
    let method = HTTPMethod.post
}
