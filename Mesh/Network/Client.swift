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
    
    func upload(_ request : PhotoRequest, completionHandler: @escaping (Response<Any, NSError>) -> Void) {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                //multipartFormData.append(request.file, withName: "picture")
                multipartFormData.append(request.file, withName: "picture", fileName: "file.jpg", mimeType: "image/jpeg")
            },
            to: baseURL + request.path,
            withMethod: .post,
            headers: request.headers(),
            encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: completionHandler)
                    break
                case .failure:
                    break
                }
            }
        )
    }
    
    func execute(_ request : Request, completionHandler: @escaping (Response<Any, NSError>) -> Void) {
        var params = request.parameters()
        if UserResponse.currentUser?._id != nil {
            params["uid"] = UserResponse.currentUser?._id
        }
        
        Alamofire.request(baseURL + request.path, withMethod: request.method, parameters: params, encoding: .json, headers: request.headers())
            .responseJSON { response in
                if request is LoginRequest || request is AuthRequest {
                    if response.result.error == nil {
                        UserResponse.currentUser = UserResponse(JSON: response.result.value as! [String : Any])
                        self.token = UserResponse.currentUser?.token
                        Token.persistToken(self.token!)
                        Token.persistLogin((phone_number: request.parameters()["phone_number"] as! String, password: request.parameters()["password"] as! String))
                    }
                }
                if request is LogoutRequest {
                    Token.persistToken("")
                    Token.persistLogin((phone_number: "", password: ""))
                    UserResponse.currentUser = nil
                }
                
                if let httpError = response.result.error {
                    let statusCode = httpError.code
                    if statusCode == 401 {
                        Token.persistToken("")
                        Token.persistLogin((phone_number: "", password: ""))
                        UserResponse.currentUser = nil
                    }
                }
                completionHandler(response)
        }
    }
}
