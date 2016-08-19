//
//  MessagesRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

// TODO
struct MessagesSendRequest : Request {
    let path = "message"
    let method = HTTPMethod.put
    
    var _id : Int
    
    func parameters() -> [String : Any] {
        return ["_id": _id]
    }
}

struct MessagesDeleteRequest : Request {
    let path = "message"
    let method = HTTPMethod.delete
    
    var _id : Int
    
    func parameters() -> [String : Any] {
        return ["_id": _id]
    }
}
