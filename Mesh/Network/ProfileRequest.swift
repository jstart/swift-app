//
//  ProfileRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/17/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import Alamofire

struct ProfileRequest : Request {
    let path = "profile"
    let method = HTTPMethod.post
    
    var uid : String
    
    func parameters() -> [String : Any] {
        return ["uid" : uid]
    }
}

