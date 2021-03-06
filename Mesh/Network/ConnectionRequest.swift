//
//  ConnectionRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

struct ConnectionRequest : AuthenticatedRequest {
    let path = "connection", method = HTTPMethod.put
    
    let recipient : String
}

struct ConnectionDeleteRequest : AuthenticatedRequest {
    let path = "connection", method = HTTPMethod.delete
    
    let connection_id : String
}
