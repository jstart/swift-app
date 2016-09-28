//
//  AuthRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

struct AuthRequest : AuthenticatedRequest {
    let path = "auth", method = HTTPMethod.post
    
    let phone_number, password, password_verify : String
}

struct TokenRequest : Request { let path = "token", method = HTTPMethod.get }

struct LoginRequest : Request {
    let path = "login", method = HTTPMethod.post
    
    let phone_number, password : String
}

struct MessageResponse {
    let _id, sender, recipient : String, text : String?, ts : Int
    
    init(JSON: JSONDictionary) {
        _id = JSON["_id"] as! String
        ts = JSON["ts"] as! Int
        sender = JSON["sender"] as! String
        recipient = JSON["recipient"] as! String
        text = (JSON["text"] as? String) ?? ""
    }
}

struct ConnectionResponse {
    let _id: String,
        user: UserResponse
    var read, muted: Bool,
        update_date: Date
    
    init(JSON: JSONDictionary) {
        _id = JSON["_id"] as! String
        user = UserResponse(JSON: JSON)
        read = JSON["read"] as? Bool ?? true
        muted = JSON["read"] as? Bool ?? false
        let date = (JSON["update_date"] as? Int) ?? 0
        update_date = Date(timeIntervalSince1970: TimeInterval(date/1000))
    }
}

struct UserResponse {
    static var current : UserResponse?
    static var connections = [ConnectionResponse]()
    static var messages = [MessageResponse]()

    var _id : String,
        phone_number, email, first_name, last_name, profession, title, token : String?,
        companies : [CompanyModel]?,
        photos : PhotoResponse?,
        position : PositionResponse?
    
    init(JSON: JSONDictionary) {
        _id = JSON["_id"] as! String
        _id = (JSON["user_id"] as? String?)! ?? _id
        phone_number = (JSON["phone_number"] as? String?)!
        email = (JSON["email"] as? String?)!
        first_name = (JSON["first_name"] as? String) ?? ""
        last_name = (JSON["last_name"] as? String) ?? ""
        title = (JSON["title"] as? String?) ?? ""
        if let companiesJSON = JSON["companies"] as? JSONArray { companies = companiesJSON.map({return CompanyModel.create(JSON: $0)}) }
        profession = (JSON["profession"] as? String?) ?? ""
        token = (JSON["token"] as? String?) ?? ""
        if JSON["profile_photo"] != nil { photos = PhotoResponse(JSON:(JSON["profile_photo"] as! JSONDictionary)) }
        if JSON["position"] != nil { position = PositionResponse(JSON:(JSON["position"] as! JSONDictionary)) }
    }
    
    func fullName() -> String { return (first_name ?? "") + " " + (last_name ?? "") }
    
    func fullTitle() -> String {
        guard let company = companies?.first else { return title ?? "" }
        return (title ?? "") + " at " + company.id
    }
    
    func searchText() -> String {
        let companyNames = companies?.map({return $0.id}).joined(separator: " ")
        return fullName() + (title ?? "") + (companyNames ?? "") // profession?
    }
}

struct PhotoResponse {
    let small, medium, large : String
    
    init(JSON: [String : Any]) { small = (JSON["small"] as? String)!.trim; medium = (JSON["medium"] as? String)!.trim; large = (JSON["large"] as? String)!.trim }
}

struct PositionResponse {
    let lat : Double, lon : Double
    
    init(JSON: [String : Any]) { lat = JSON["lat"] as! Double; lon = JSON["lon"] as! Double }
}

struct LogoutRequest : AuthenticatedRequest { let path = "logout", method = HTTPMethod.post }
