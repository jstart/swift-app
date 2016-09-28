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
        
    static func latest() -> UpdatesRequest { return UpdatesRequest(last_update: (StandardDefaults["last_update"] as? Int) ?? 0) }
    static func fresh() -> UpdatesRequest { return UpdatesRequest(last_update: 0) }
    
    static func append(_ response: DataResponse<Any>, callback: @escaping (() -> Void) = {}) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let json = response.result.value as? JSONDictionary else { return }
            
            guard let last_update = json["last_update"] as? Int else { return }
            StandardDefaults.set(last_update + 1, forKey: "last_update")
            
            guard let connectionsJSON = ((json["connections"] as? JSONDictionary)?["connections"] as? JSONArray) else { self.appendMessages(json); return }
            let connections = connectionsJSON.map({ return ConnectionResponse(JSON: $0) }).filter({ return $0.user._id != UserResponse.current?._id }).sorted(by: { return $0.user.first_name! < $1.user.first_name! })
            UserResponse.connections.append(contentsOf: connections)
            
            appendMessages(json)
            DispatchQueue.main.async { callback() }
        }
    }
    
    static func appendMessages(_ json : JSONDictionary){
        guard let messages = (json["messages"] as? JSONDictionary)?["messages"] as? JSONArray else { return }
        UserResponse.messages.append(contentsOf: messages.map({return MessageResponse(JSON: $0)}).sorted(by: { $0.ts > $1.ts}))
    }
}

struct RecommendationsRequest : AuthenticatedRequest { let path = "recommendations", method = HTTPMethod.get }

struct RecommendationResponse {
    let type : String, user: UserResponse?, tweet: TweetResponse?
    
    init(JSON: [String : Any]) {
        type = (JSON["type"] as? String)!

        if type == "tweet" { tweet = TweetResponse(JSON: JSON) }
        else { tweet = nil }
        
        if type == "tweet" { user = UserResponse(JSON: JSON["user"] as! [String: Any]) }
        else if type == "person" { user = UserResponse(JSON: JSON) }
        else { user = nil }
    }
    
    func cardType() -> CardType { return CardType(rawValue: type)! }
    func contentType() -> Content { return .article }
}

struct TweetResponse {
    let text, name, screen_name, _id, uid: String, created_at: String
    
    init(JSON: [String : Any]) {
        text = (JSON["text"] as? String)!
        name = (JSON["name"] as? String)!
        screen_name = (JSON["screen_name"] as? String)!
        _id = (JSON["_id"] as? String)!
        uid = (JSON["uid"] as? String)!
        created_at = (JSON["created_at"] as? String)!
    }
}

struct LikeRequest : AuthenticatedRequest {
    let path = "recommendations/like", method = HTTPMethod.put
    
    let _id : String
}

struct LikeContactRequest : AuthenticatedRequest {
    let path = "recommendations/like", method = HTTPMethod.put
    
    let phone_number: String?, email: String?
    
    func parameters() -> [String : Any] { return phone_number != nil ? ["phone_number": phone_number!] : ["email": email!] }
}

struct PassRequest : AuthenticatedRequest {
    let path = "recommendations/pass", method = HTTPMethod.put
    
    let _id : String
}
