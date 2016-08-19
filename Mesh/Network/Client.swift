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

protocol AuthenticatedRequest : Request {
}

extension AuthenticatedRequest {
    func headers() -> [String : String] {
        
         return ["token" : Token.retrieveToken() ?? ""]
    }
}

extension Request {
    func parameters () -> [String : Any]{
        return [:]
    }
    func headers() -> [String : String] {
        return [:]
    }
}

//["phone_number": "3103479814", "password" : "password", "password_verify" : "password", "first_name" : "chris", "last_name" : "truman", "email" : "christopher@tinderventures.com", "company" : "tinder", "profession" : "iOS"]
class Client {
    
    var baseURL = "http://dev.mesh.tinderventures.com:1337/"
    var token : String?
    var uid : String?
    func execute(_ request : Request, completionHandler: @escaping (Response<Any, NSError>) -> Void){
        var params = request.parameters()
        if uid != nil {
            params["uid"] = uid
        }
        Alamofire.request(baseURL + request.path, withMethod: request.method, parameters: params, encoding: .json, headers: request.headers() )
            .responseJSON { response in
                if request is LoginRequest || request is AuthRequest {
                    if response.result.error == nil {
                        self.token = UserResponse(JSON: response.result.value as! [String : Any]).token
                        Token.persistToken(self.token!)
                        self.uid = UserResponse(JSON: response.result.value as! [String : Any])._id
                    }
                }
                completionHandler(response)
        }
    }
}
