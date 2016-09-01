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
    let path = "profile"
    let method = HTTPMethod.post
    
    var first_name : String
    var last_name : String
    var email : String
    var title : String
    var profession : String
    var companies : [CompanyModel]
    
    func parameters() -> [String : Any] {
        return ["first_name" : first_name, "last_name" : last_name, "email" : email, "title" : title, "profession" : profession, "companies" : companies.map({$0.parameters()})]
    }
}

struct CompanyModel {
    var id : String
    var start_month : String
    var start_year : String
    var end_month : String
    var end_year : String
    var current : Bool
    
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
    let path = "photo"
    let method = HTTPMethod.post
    
    var file : Data
}

