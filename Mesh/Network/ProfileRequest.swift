//
//  ProfileRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/17/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import Alamofire

struct ProfileRequest : AuthenticatedRequest {
    let path = "profile", method = HTTPMethod.post
    
    var first_name, last_name, email, title, profession : String?,
        companies : [CompanyModel]?
    
    func parameters() -> [String : Any] {
        var parameters = [String : Any]()
        if first_name != nil { parameters["first_name"] = first_name! }
        if last_name != nil { parameters["last_name"] = last_name! }
        if email != nil { parameters["email"] = email! }
        if title != nil { parameters["title"] = title! }
        if profession != nil { parameters["profession"] = profession! }
        if companies != nil { parameters["companies"] = companies!.map({$0.parameters()}) }

        return parameters
    }
    
    init(first_name: String? = nil, last_name: String? = nil, email: String? = nil, title: String? = nil, profession: String? = nil, companies: [CompanyModel]? = nil) {
        self.first_name = first_name; self.last_name = last_name
        self.email = email; self.title = title
        self.profession = profession; self.companies = companies
    }
}

struct CompanyModel {
    let id : String,
        start_month, start_year, end_month, end_year : String,
        current : Bool
    
    func parameters() -> [String : Any] { return ["_id" : id, "start_month" : start_month, "start_year" : start_year, "end_month" : end_month, "end_year" : end_year, "current" : current] }
    
    static func create(JSON: JSONDictionary) -> CompanyModel{
        let id = JSON["id"] as? String ?? "",
            start_month = JSON["start_month"] as? String ?? "",
            start_year = JSON["start_year"] as? String ?? "",
            end_month = JSON["end_month"] as? String ?? "",
            end_year = JSON["end_year"] as? String ?? "",
            current = JSON["current"] as? Bool ?? false
        
        return CompanyModel(id: id, start_month: start_month, start_year: start_year, end_month: end_month, end_year: end_year, current: current)
    }
}

struct PhotoRequest : AuthenticatedRequest {
    let path = "photo", method = HTTPMethod.post
    
    let file : Data
}

