//
//  AuthRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire
import RealmSwift

struct AuthRequest : AuthenticatedRequest {
    let path = "auth", method = HTTPMethod.post
    
    let phone_number, password, password_verify : String
}

struct TokenRequest : Request { let path = "token", method = HTTPMethod.get }

struct LoginRequest : Request {
    let path = "login", method = HTTPMethod.post
    
    let phone_number, password : String
}

class MessageResponse : Object {
    dynamic var _id = "", sender = "", recipient = "", text : String?, ts = 0
    
    override class func primaryKey() -> String? { return "_id" }
    override class func indexedProperties() -> [String] { return ["ts"] }

    static func create(_ JSON: JSONDictionary)  -> MessageResponse {
        return MessageResponse().then {
            $0._id = JSON["_id"] as! String
            $0.ts = JSON["ts"] as! Int
            $0.sender = JSON["sender"] as! String
            $0.recipient = JSON["recipient"] as! String
            $0.text = (JSON["text"] as? String) ?? ""
        }
    }
}

class ConnectionResponse : Object, UserDetail {
    var category: QuickViewCategory { return .connections }

    dynamic var _id = "", user: UserResponse?
    dynamic var read = false, muted = false,
        update_date: Date?
    
    var firstText: String { return (user?.initialName()) ?? "" }
    var secondText: String { return (user?.fullTitle()) ?? "" }
    var logo: String? { return user?.photos?.large }
    
    override class func primaryKey() -> String? { return "_id" }

    static func create(_ JSON: JSONDictionary) -> ConnectionResponse {
        return ConnectionResponse().then {
            $0._id = JSON["_id"] as! String
            $0.user = UserResponse.create(JSON)
            $0.read = JSON["read"] as? Bool ?? true
            $0.muted = JSON["read"] as? Bool ?? false
            let date = (JSON["update_date"] as? Int) ?? 0
            $0.update_date = Date(timeIntervalSince1970: TimeInterval(date/1000))
        }
    }
}

class UserResponse : Object, UserDetail {
    let category = QuickViewCategory.connections

    static var current : UserResponse?
    static var connections = [ConnectionResponse]()
    static var messages = [MessageResponse]()
    static var events = [EventResponse]()
    static var cards = [CardResponse]()
    
    dynamic var _id = "",
        phone_number, email, first_name, last_name, profession, title, token, promoted_category, first_company_id : String?
    let companies = List<CompanyResponse>(),
        schools = List<SchoolResponse>(),
        interests = List<InterestResponse>(),
        common_connections = List<UserResponse>(),
        events = List<EventResponse>()
    
    dynamic var photos : PhotoResponse?, position : PositionResponse?
    
    override class func primaryKey() -> String? { return "_id" }
    override class func indexedProperties() -> [String] { return ["first_name", "last_name"] }
    static func create(_ JSON: JSONDictionary) -> UserResponse {
        return UserResponse().then { object in
                object._id = JSON["_id"] as! String
                object._id = (JSON["user_id"] as? String?)! ?? object._id
                object.phone_number = (JSON["phone_number"] as? String?)!?.replace("+1", with: "")
                object.email = (JSON["email"] as? String?)!
                object.first_name = (JSON["first_name"] as? String)
                object.last_name = (JSON["last_name"] as? String)
                object.promoted_category = (JSON["promoted_category"] as? String)

                object.title = (JSON["title"] as? String?) ?? ""
                if let companiesJSON = JSON["companies"] as? JSONArray {
                    companiesJSON.forEach({ company in
                        if let current = company["current"] as? Bool {
                            if current == true {
                                object.first_company_id = (company["id"] as? String)
                                if object.first_company_id == nil { object.first_company_id = "\(company["_id"] as? Int)" }
                            }
                        }
                    })
                }

                if let companiesJSON = JSON["companies"] as? JSONArray { object.companies.append(objectsIn: companiesJSON.map({return CompanyResponse.create($0)})) }
                if let interestsJSON = JSON["interests"] as? JSONArray { object.interests.append(objectsIn: interestsJSON.map({return InterestResponse.create($0)})) }
                if let schoolsJSON = JSON["schools"] as? JSONArray { object.schools.append(objectsIn: schoolsJSON.map({return SchoolResponse.create($0)})) }
                object.profession = (JSON["profession"] as? String?) ?? ""
                object.token = (JSON["token"] as? String?) ?? ""
                if JSON["profile_photo"] != nil { object.photos = PhotoResponse.create((JSON["profile_photo"] as! JSONDictionary)) }
                if JSON["photos"] != nil { object.photos = PhotoResponse.create((JSON["photos"] as! JSONDictionary)) }
                if JSON["position"] != nil { object.position = PositionResponse.create((JSON["position"] as! JSONDictionary)) }
                if let commonConnectionsJSON = JSON["common_connections"] as? JSONArray { object.common_connections.append(objectsIn: commonConnectionsJSON.map({return UserResponse.create( $0)})) }
                if let eventsJSON = JSON["events"] as? JSONArray { object.events.append(objectsIn: eventsJSON.map({return EventResponse.create( $0)})) }
        }
    }
    
    func fullName() -> String { return (first_name ?? "") + " " + (last_name ?? "") }
    func initialName() -> String { return (first_name ?? "") + " " + (last_name?.stringFrom(0, to: 1) ?? "") }

    func fullTitle() -> String {
        guard let company = firstCompany else { return title ?? "" }
        return (title ?? "") + " at " + (company.name ?? "")
    }
    
    func searchText() -> String {
        let companyNames = companies.flatMap({return $0.name}).joined(separator: " ")
        return fullName() + (title ?? "") + companyNames // profession?
    }
    
    var firstCompany: CompanyResponse? {
        for company in companies {
            if company._id == first_company_id { return company }
        }
        return companies.first
    }
    
    var firstText: String { return (initialName()) }
    var secondText: String { return fullTitle() }
    var logo: String? { guard let photo = photos?.large else { return nil }; return photo }
}

class PhotoResponse : Object {
    dynamic var small, medium, large : String?
    
    static func create(_ JSON: JSONDictionary) -> PhotoResponse {
        return PhotoResponse().then {
            $0.small = (JSON["small"] as? String)!.trim; $0.medium = (JSON["medium"] as? String)!.trim; $0.large = (JSON["large"] as? String)!.trim
        }
    }
}

class PositionResponse : Object {
    dynamic var lat : Double = 0, lon : Double = 0
    
    static func create(_ JSON: JSONDictionary) -> PositionResponse {
        return PositionResponse().then { $0.lat = JSON["lat"] as! Double; $0.lon = JSON["lon"] as! Double }
    }
}

class CompanyResponse : Object, UserDetail {
    dynamic var _id, name, start_year, end_year, logo : String?, current = 0
    override class func primaryKey() -> String? { return "_id" }
    override class func indexedProperties() -> [String] { return ["name"] }

    static func create(_ JSON: JSONDictionary) -> CompanyResponse {
        return CompanyResponse().then {
            $0._id = JSON["_id"] as? String; $0.name = JSON["name"] as? String; $0.logo = JSON["logo"] as? String;
            if let start = JSON["start_year"] as? Int { $0.start_year = "\(start)" }
            if let end = JSON["end_year"] as? Int { $0.end_year = "\(end)" }
            //if let current = JSON["current"] as? Bool { $0.current = Int(current) } else { $0.current = 0 }
            if $0._id == nil { $0._id = "\(JSON["_id"] as? Int)" }
        }
    }

    var firstText: String { return (name ?? "") }
    var secondText: String {
        if start_year != nil && end_year == nil {
            return "\(start_year!) - Present"
        } else if start_year != nil && end_year != nil {
            return "\(start_year!) - \(end_year!)"
        }
        return ""
    }
    
    func fieldValues() -> [Any] { return [name!] }
    
    let category = QuickViewCategory.experience
}

class InterestResponse : Object, UserDetail {
    dynamic var _id, name, logo : String?
    override class func primaryKey() -> String? { return "_id" }
    override class func indexedProperties() -> [String] { return ["name"] }

    static func create(_ JSON: JSONDictionary) -> InterestResponse {
        return InterestResponse().then {
            $0._id = JSON["_id"] as? String; $0.name = JSON["name"] as? String; $0.logo = JSON["logo"] as? String
        }
    }
    
    var firstText: String { return (name ?? "") }
    
    let category = QuickViewCategory.skills
}

class SchoolResponse : Object, UserDetail {
    dynamic var _id, name, start_year, end_year, logo : String?
    override class func primaryKey() -> String? { return "_id" }
    override class func indexedProperties() -> [String] { return ["name"] }

    static func create(_ JSON: JSONDictionary) -> SchoolResponse {
        return SchoolResponse().then {
            $0._id = JSON["_id"] as? String; $0.name = JSON["name"] as? String; $0.logo = JSON["logo"] as? String

            if let start = JSON["start_year"] as? Int { $0.start_year = "\(start)" }
            if let end = JSON["end_year"] as? Int { $0.end_year = "\(end)" }
        }
    }
    
    func fieldValues() -> [Any] { return [name!] }
    
    var firstText: String { return (name ?? "") }
    var secondText: String {
        if start_year != nil && end_year == nil {
            return "\(start_year!) - Present"
        } else if start_year != nil && end_year != nil {
            return "\(start_year!) - \(end_year!)"
        }
        return ""
    }

    let category = QuickViewCategory.education
}

struct LogoutRequest : AuthenticatedRequest { let path = "logout", method = HTTPMethod.post }
