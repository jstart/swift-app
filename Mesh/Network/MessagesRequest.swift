//
//  MessagesRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

struct MessagesSendRequest : AuthenticatedRequest {
    let path = "message", method = HTTPMethod.put
    
    let recipient, text : String
}

// TODO: edit
struct MessagesEditRequest : AuthenticatedRequest {
    let path = "message", method = HTTPMethod.put
    
    let _id, message : String
}

struct MessagesDeleteRequest : AuthenticatedRequest {
    var path : String { return "message" }
    let method = HTTPMethod.delete
    
    let _id : String
    
    init(id : String) { _id = id }
}

struct MarkReadRequest : AuthenticatedRequest {
    var path : String { return "connection/" + (read ? "read" : "unread") }
    let method = HTTPMethod.post
    
    let read : Bool, _id : String
    
    init(read: Bool, id : String) { self.read = read; _id = id }
}
