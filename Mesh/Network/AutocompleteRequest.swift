//
//  AutocompleteRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 10/6/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire
import RealmSwift

struct SchoolsAutocompleteRequest : AuthenticatedRequest {
    let path = "schools", method = HTTPMethod.get
    
    let q : String
}

struct CompanyAutocompleteRequest : AuthenticatedRequest {
    let path = "companies", method = HTTPMethod.get
    
    let q : String
}

struct InterestsAutocompleteRequest : AuthenticatedRequest {
    let path = "interests", method = HTTPMethod.get
    
    let q : String
}

struct PickerRequest : AuthenticatedRequest {
    let path = "picker", method = HTTPMethod.get
    
    //let parent : String
}

class PickerResponse : Object {
    dynamic var _id : Int = 0
    dynamic var name, logo : String?
    let children = List<PickerResponse>()
    
    static func create(_ JSON: JSONDictionary) -> PickerResponse {
        return PickerResponse().then {
            $0._id = (JSON["_id"] as? Int)!
            $0.name = (JSON["name"] as? String)!
            $0.logo = (JSON["logo"] as? String)!
            if let childrenJSON = JSON["children"] as? JSONArray { $0.children.append(objectsIn: childrenJSON.map({ return PickerResponse.create($0)}))}
        }
    }
}
