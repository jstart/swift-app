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

// TODO: edit
struct MessagesEditRequest : AuthenticatedRequest {
    let path = "message"
    let method = HTTPMethod.put
    
    var _id : String
    var message : String
    
    func parameters() -> [String : Any] {
        return ["_id": _id, "message" : message]
    }
}

struct MessagesDeleteRequest : AuthenticatedRequest {
    var path : String {
        get {
           return "message" + "/" + _id
        }
    }
    
    let method = HTTPMethod.delete
    
    var _id : String
    
    init(id : String) {
        _id = id
    }
    
    func parameters() -> [String : Any] {
        return ["_id": _id]
    }
}
