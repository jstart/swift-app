//
//  AutocompleteRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 10/6/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

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
