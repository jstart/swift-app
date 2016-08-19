//
//  PositionRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/17/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import Alamofire

struct PositionRequest : Request {
    let path = "position"
    let method = HTTPMethod.post
    
    var lat : Double
    var lon : Double
    var uid : String
    
    func parameters() -> [String : AnyObject] {
        return ["lat" : lat, "lon" : lon, "uid" : uid]
    }
}
