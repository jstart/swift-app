//
//  PositionRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/17/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import Alamofire

struct PositionRequest : AuthenticatedRequest {
    let path = "position", method = HTTPMethod.post
    
    let lat : Double, lon : Double
    
    func parameters() -> [String : Any] { return ["lat" : lat, "lon" : lon] }
}
