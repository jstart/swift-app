//
//  EventsRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 10/1/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

struct EventCreateRequest : AuthenticatedRequest {
    let path = "event", method = HTTPMethod.put
    
    let name, logo, description : String, interests : [Int], start_time, end_time : Double
}

struct EventLikeRequest : AuthenticatedRequest {
    let path = "event/like", method = HTTPMethod.put
    
    let _id : String
}

struct EventPassRequest : AuthenticatedRequest {
    let path = "event/pass", method = HTTPMethod.put
    
    let _id : String
}
