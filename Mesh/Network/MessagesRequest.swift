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
    
    let recipient : String, text : String
    
    func parameters() -> [String : Any] { return ["recipient": recipient, "text" : text] }
}

// TODO: edit
struct MessagesEditRequest : AuthenticatedRequest {
    let path = "message", method = HTTPMethod.put
    
    let _id : String, message : String
    
    func parameters() -> [String : Any] {
        return ["_id": _id, "message" : message]
    }
}

struct MessagesDeleteRequest : AuthenticatedRequest {
    var path : String { return "message" + "/" + _id }
    let method = HTTPMethod.delete
    
    let _id : String
    
    init(id : String) { _id = id }
    
    func parameters() -> [String : Any] { return ["_id": _id] }
}
