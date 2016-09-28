//
//  ConnectAccountRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 9/20/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import Alamofire

struct TwitterConnectRequest : AuthenticatedRequest {
    let path = "account/twitter", method = HTTPMethod.put
    
    var twitter_token, twitter_secret : String
}

struct MediumConnectRequest : AuthenticatedRequest {
    let path = "account/medium", method = HTTPMethod.put
    
    var medium_token : String
}
