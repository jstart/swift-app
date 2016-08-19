//
//  UpdatesRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

struct UpdatesRequest : Request {
    let path = "updates"
    let method = HTTPMethod.post
    
    var last_update : Int
    
    func parameters() -> [String : Any] {
        return ["last_update": last_update]
    }
}

struct RecommendationsRequest : Request {
    let path = "recommendations"
    let method = HTTPMethod.post
}
