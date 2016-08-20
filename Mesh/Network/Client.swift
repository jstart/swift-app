//
//  Client.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

protocol Request {
    var path : String { get }
    var method : HTTPMethod { get }
    func parameters() -> [String : Any]
    func headers() -> [String : String]
}

protocol AuthenticatedRequest : Request {}

extension AuthenticatedRequest {
    func headers() -> [String : String] {
         return ["token" : Token.retrieveToken() ?? ""]
    }
}

extension Request {
    func parameters () -> [String : Any] {
        return [:]
    }
    func headers() -> [String : String] {
        return [:]
    }
}

class Client {
    var baseURL = "http://dev.mesh.tinderventures.com:1337/"
    var token : String?
    var uid : String?
    
    func execute(_ request : Request, completionHandler: @escaping (Response<Any, NSError>) -> Void) {
        var params = request.parameters()
        if uid != nil {
            params["uid"] = uid
        }
        Alamofire.request(baseURL + request.path, withMethod: request.method, parameters: params, encoding: .json, headers: request.headers())
            .responseJSON { response in
                if request is LoginRequest || request is AuthRequest {
                    if response.result.error == nil {
                        UserResponse.currentUser = UserResponse(JSON: response.result.value as! [String : Any])
                        self.token = UserResponse.currentUser?.token
                        Token.persistToken(self.token!)
                        Token.persistLogin((phone_number: request.parameters()["phone_number"] as! String, password: request.parameters()["password"] as! String))
                        self.uid = UserResponse.currentUser?._id
                    }
                }
                if request is LogoutRequest {
                    Token.persistToken("")
                    Token.persistLogin((phone_number: "", password: ""))
                    UserResponse.currentUser = nil
                }
                completionHandler(response)
        }
    }
}
