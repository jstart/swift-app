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
    func parameters() -> [String : AnyObject]
}

extension Request {
    func parameters () -> [String : AnyObject]{
        return [:]
    }
}

//["phone_number": "3103479814", "password" : "password", "password_verify" : "password", "first_name" : "chris", "last_name" : "truman", "email" : "christopher@tinderventures.com", "company" : "tinder", "profession" : "iOS"]
class Client {
    
    var baseURL = "http://dev.mesh.tinderventures.com:1337/"
    var token : String?
    
    func execute(_ request : Request, completionHandler: (Response<AnyObject, NSError>) -> Void){
        Alamofire.request(baseURL + request.path, withMethod: request.method, parameters: request.parameters(), encoding: .json, headers: ["token" : token ?? ""] )
            .responseJSON { response in
                if request is LoginRequest {
                    self.token = UserResponse(JSON: response.result.value as! [String : AnyObject]).token
                }
                completionHandler(response)
        }
    }
}
