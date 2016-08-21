//
//  MessagesRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

struct MessagesSendRequest : AuthenticatedRequest {
    let path = "message"
    let method = HTTPMethod.put
    
    var recipient : String
    var text : String
    
    func parameters() -> [String : Any] {
        return ["recipient": recipient, "text" : text]
    }
}

// TODO:
struct MessagesDeleteRequest : AuthenticatedRequest {
    let path = "message"
    let method = HTTPMethod.delete
    
    var _id : Int
    
    func parameters() -> [String : Any] {
        return ["_id": _id]
    }
}
