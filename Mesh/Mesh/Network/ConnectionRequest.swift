//
//  ConnectionRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

struct ConnectionRequest : Request {
    let path = "connection"
    let method = Method.GET
}
