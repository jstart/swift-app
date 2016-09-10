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
    
    static func latest() -> UpdatesRequest { return UpdatesRequest(last_update: (UserDefaults.standard["last_update"] as? Int) ?? 0) }
    
    static func fresh() -> UpdatesRequest { return UpdatesRequest(last_update: 0) }
    
    static func append(_ response: Response<Any, NSError>) {
        guard let json = response.result.value as? JSONDictionary else { return }
        
        guard let last_update = json["last_update"] as? Int else { return }
        UserDefaults.standard.set(last_update + 1, forKey: "last_update")
        
        guard let connections = ((json["connections"] as? JSONDictionary)?["connections"] as? JSONArray) else { self.appendMessages(json); return }
        UserResponse.connections.append(contentsOf: connections.map({ return Connection(JSON: $0) }).filter({ return $0.user._id != UserResponse.current?._id }).sorted(by: { return $0.user.first_name! < $1.user.first_name! }))
        
        appendMessages(json)
    }
    
    static func appendMessages(_ json : JSONDictionary){
        guard let messages = (json["messages"] as? JSONDictionary)?["messages"] as? JSONArray else { return }
        UserResponse.messages.append(contentsOf: messages.map({return MessageResponse(JSON: $0)}).sorted(by: { $0.ts > $1.ts}))
    }
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


