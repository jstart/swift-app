//
//  UpdatesRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

struct UpdatesRequest : AuthenticatedRequest {
    let path = "updates"
    let method = HTTPMethod.post
    
    var last_update : Int
    
    func parameters() -> [String : Any] {
        return ["last_update": last_update]
    }
}

struct RecommendationsRequest : AuthenticatedRequest {
    let path = "recommendations"
    let method = HTTPMethod.get
}

struct LikeRequest : AuthenticatedRequest {
    let path = "recommendations/like"
    let method = HTTPMethod.put
    
    var _id : String
    
    func parameters() -> [String : Any] {
        return ["_id": _id]
    }
}

struct PassRequest : AuthenticatedRequest {
    let path = "recommendations/pass"
    let method = HTTPMethod.put
    
    var _id : String
    
    func parameters() -> [String : Any] {
        return ["_id": _id]
    }
}


