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

struct MessageResponse {
    var _id : String
    var ts : Int
    var sender : String
    var recipient : String
    var text : String?
    
    init(JSON: JSONDictionary) {
        _id = JSON["_id"] as! String
        ts = JSON["ts"] as! Int
        sender = JSON["sender"] as! String
        recipient = JSON["recipient"] as! String
        text = (JSON["text"] as? String) ?? ""
    }
}

struct UserResponse {
    static var currentUser : UserResponse?
    static var connections : [UserResponse]?
    static var messages : [MessageResponse]?

    var _id : String
    var phone_number : String?
    var first_name : String?
    var last_name : String?
    var companies : [CompanyModel]?
    var profession : String?
    var title : String?
    var photos : PhotoResponse?
    var position : PositionResponse?
    var token : String?
    
    init(JSON: JSONDictionary) {
        _id = JSON["_id"] as! String
        _id = (JSON["user_id"] as? String?)! ?? _id
        phone_number = (JSON["phone_number"] as? String?)!
        first_name = (JSON["first_name"] as? String?)!
        last_name = (JSON["last_name"] as? String?)!
        title = (JSON["title"] as? String?)!
        if let companiesJSON = JSON["companies"] as? JSONArray{
            companies = companiesJSON.map({return CompanyModel.create(JSON: $0)})
        }
        profession = (JSON["profession"] as? String?)!
        token = (JSON["token"] as? String?)!
        if JSON["profile_photo"] != nil{
            photos = PhotoResponse(JSON:(JSON["profile_photo"] as! JSONDictionary))
        }
        if JSON["position"] != nil{
            position = PositionResponse(JSON:(JSON["position"] as! JSONDictionary))
        }
    }
    
    func fullName() -> String {
        return (first_name ?? "") + " " + (last_name ?? "")
    }
    
    func searchText() -> String {
        let companyNames = companies?.map({return $0.id}).joined(separator: " ")
        return fullName() + (title ?? "") + (companyNames ?? "") // profession?
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
