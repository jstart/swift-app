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
    
    let first_name : String,
        last_name : String,
        email : String,
        title : String,
        profession : String,
        companies : [CompanyModel]
    
    func parameters() -> [String : Any] {
        return ["first_name" : first_name, "last_name" : last_name, "email" : email, "title" : title, "profession" : profession, "companies" : companies.map({$0.parameters()})]
    }
}

struct CompanyModel {
    let id : String,
        start_month : String,
        start_year : String,
        end_month : String,
        end_year : String,
        current : Bool
    
    func parameters() -> [String : Any] {
        return ["id" : id, "start_month" : start_month, "start_year" : start_year, "end_month" : end_month, "end_year" : end_year, "current" : current]
    }
    
    static func create(JSON: JSONDictionary) -> CompanyModel{
        let id = JSON["id"] as? String ?? ""
        let start_month = JSON["start_month"] as? String ?? ""

        let start_year = JSON["start_year"] as? String ?? ""
        let end_month = JSON["end_month"] as? String ?? ""
        let end_year = JSON["end_year"] as? String ?? ""
        let current = JSON["current"] as? Bool ?? false
        
        return CompanyModel(id: id, start_month: start_month, start_year: start_year, end_month: end_month, end_year: end_year, current: current)
    }
}

struct PhotoRequest : AuthenticatedRequest {
    let path = "photo", method = HTTPMethod.post
    
    let file : Data
}

