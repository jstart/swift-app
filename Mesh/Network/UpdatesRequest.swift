//
//  UpdatesRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire
import RealmSwift

struct UpdatesRequest : AuthenticatedRequest {
    let path = "updates", method = HTTPMethod.post
    
    let last_update : Int
    static let queue = DispatchQueue.global(qos: .userInitiated)
    static func latest() -> UpdatesRequest { return UpdatesRequest(last_update: (StandardDefaults["last_update"] as? Int) ?? 0) }
    static func fresh() -> UpdatesRequest { return UpdatesRequest(last_update: 0) }
    
    static func append(_ response: DataResponse<Any>, callback: @escaping (() -> Void) = {}) {
        queue.async {
            guard let json = response.result.value as? JSONDictionary else { return }
            
            if let last_update = json["last_update"] as? Int {
                StandardDefaults.set(last_update + 1, forKey: "last_update")
            }
            
            var connections : [ConnectionResponse]?
            if let connectionsJSON = ((json["connections"] as? JSONDictionary)?["connections"] as? JSONArray) {
                connections = connectionsJSON.map({ return ConnectionResponse.create( $0) })
            }
            var messages : [MessageResponse]?
            if let messageJSON = (json["messages"] as? JSONDictionary)?["messages"] as? JSONArray {
                messages = messageJSON.map({return MessageResponse.create( $0)})
            }
            var events : [EventResponse]?
            if let eventJSON = (json["events"] as? JSONDictionary)?["events"] as? JSONArray {
                events = eventJSON.map({return EventResponse.create( $0)})
            }
            
            let realm = RealmUtilities.realm()
            realm.refresh()
            try! realm.write {
                if let connections = connections { realm.add(connections, update: true) }
                if let messages = messages { realm.add(messages, update: true) }
                if let events = events { realm.add(events, update: true) }
            }
            
            DispatchQueue.main.async {
                let realm = RealmUtilities.realm()
                realm.refresh()
                UserResponse.connections = Array(realm.objects(ConnectionResponse.self));
                UserResponse.messages = Array(realm.objects(MessageResponse.self)).sorted(by: { $0.ts > $1.ts });
                UserResponse.events = Array(realm.objects(EventResponse.self)).sorted(by: { $0.start_time > $1.start_time });
                callback()
            }
        }
    }
    
}

struct RecommendationsRequest : AuthenticatedRequest { let path = "recommendations", method = HTTPMethod.get }

class RecommendationResponse : Object {
    dynamic var type : String = "", user: UserResponse?, tweet: TweetResponse?, event: EventResponse?
    //override class func primaryKey() -> String? { return "type" } // TODO: Rec ID

    static func create(_ JSON: JSONDictionary) -> RecommendationResponse {
        return RecommendationResponse().then {
            $0.type = (JSON["type"] as? String)!
            
            if $0.type == "tweet" { $0.tweet = TweetResponse.create(JSON["tweet"] as! JSONDictionary) }
            else { $0.tweet = nil }
            
            if JSON["user"] != nil && JSON["user"] is JSONDictionary { $0.user = UserResponse.create(JSON["user"] as! JSONDictionary) }
            else { $0.user = nil }
            
            if JSON["event"] != nil { $0.event = EventResponse.create(JSON["event"] as! JSONDictionary) }
            else { $0.event = nil }
        }
    }
    
    func cardType() -> CardType { return CardType(rawValue: type)! }
    func contentType() -> Content { return .article }
}

class TweetResponse : Object {
    dynamic var text = "", _id = "", name = "", screen_name : String? //, uid, created_at: String
    override class func primaryKey() -> String? { return "_id" }

    static func create(_ JSON: JSONDictionary) -> TweetResponse {
        return TweetResponse().then {
            $0.text = (JSON["text"] as? String)!
            $0.name = (JSON["name"] as? String)!
            $0.screen_name = JSON["screen_name"] as? String
            $0._id = (JSON["_id"] as? String)!
            //        uid = (JSON["uid"] as? String)!
            //        created_at = (JSON["created_at"] as? String)!
        }
    }
}

class EventResponse : Object, UserDetail {
    dynamic var _id = "", name = "", logo = "", descriptionText = "", start_time = "", end_time = ""//, interests = RLMArray<Int>?
    override class func primaryKey() -> String? { return "_id" }
    override class func indexedProperties() -> [String] { return ["name", "start_time"] }

    let category = QuickViewCategory.events

    var firstText : String { return name }
    var secondText : String { return descriptionText }
    
    static func create(_ JSON: JSONDictionary) -> EventResponse {
        return EventResponse().then {
            $0._id = (JSON["_id"] as? String)!
            $0.descriptionText = (JSON["description"] as? String)!
            $0.name = (JSON["name"] as? String)!
            $0.logo = (JSON["logo"] as? String)!
            $0.start_time = (JSON["start_time"] as? String)!
            $0.end_time = (JSON["end_time"] as? String)!
            //$0.interests = (JSON["interests"] as? [Int])!
        }
    }
}

struct LikeRequest : AuthenticatedRequest {
    let path = "recommendations/like", method = HTTPMethod.put
    
    let _id : String
}

struct LikeContactRequest : AuthenticatedRequest {
    let path = "recommendations/like", method = HTTPMethod.put
    
    let phone_number: String?, email: String?
    
    func parameters() -> JSONDictionary { return phone_number != nil ? ["phone_number": phone_number!] : ["email": email!] }
}

struct PassRequest : AuthenticatedRequest {
    let path = "recommendations/pass", method = HTTPMethod.put
    
    let _id : String
}
