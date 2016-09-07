//
//  UpdatesRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

struct UpdatesRequest : AuthenticatedRequest {
    let path = "updates", method = HTTPMethod.post
    
    let last_update : Int
    
    func parameters() -> [String : Any] { return ["last_update": last_update] }
}

struct RecommendationsRequest : AuthenticatedRequest {
    let path = "recommendations", method = HTTPMethod.get
}

struct LikeRequest : AuthenticatedRequest {
    let path = "recommendations/like", method = HTTPMethod.put
    
    let _id : String
    
    func parameters() -> [String : Any] { return ["_id": _id] }
}

struct LikeContactRequest : AuthenticatedRequest {
    let path = "recommendations/like", method = HTTPMethod.put
    
    let phone_number: String?, email: String?
    
    func parameters() -> [String : Any] { return phone_number != nil ? ["phone_number": phone_number!] : ["email": email!] }
}

struct PassRequest : AuthenticatedRequest {
    let path = "recommendations/pass", method = HTTPMethod.put
    
    let _id : String
    
    func parameters() -> [String : Any] { return ["_id": _id] }
}


