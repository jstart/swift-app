//
//  Client.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire

typealias JSONDictionary = [String : Any]
typealias JSONArray = [JSONDictionary]

protocol Request {
    var path : String { get }
    var method : HTTPMethod { get }
    func parameters() -> [String : Any]
    func headers() -> [String : String]
}

protocol AuthenticatedRequest : Request {}
extension AuthenticatedRequest {
    func headers() -> [String : String] { return ["token" : Token.retrieveToken() ?? ""] }
}

extension Request {
    func parameters () -> [String : Any] { return [:] }
    func headers() -> [String : String] { return [:] }
}

extension Notification.Name {
    static let logout = NSNotification.Name("Logout")
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
            })
    }
    
    func execute(_ request : Request, completionHandler: @escaping (Response<Any, NSError>) -> Void) {
        let fullPath = baseURL + request.path
        Alamofire.request(fullPath, withMethod: request.method, parameters: request.parameters().count == 0 ? nil : request.parameters(), encoding: .json, headers: request.headers())
            .responseJSON { response in
                if request is LogoutRequest {
                    NotificationCenter.default.post(name: .logout, object: nil)
                }
                
                if let statusCode = response.result.error?.code {
                    if statusCode == 401 {
                        NotificationCenter.default.post(name: .logout, object: nil)
                    }
                }
                
                if request is LoginRequest || request is AuthRequest {
                    guard let JSON = response.result.value as? JSONDictionary else {
                        completionHandler(response)
                        return
                    }
                    UserResponse.currentUser = UserResponse(JSON: JSON)
                    self.token = UserResponse.currentUser?.token
                    Token.persistToken(self.token!)
                    Token.persistLogin((phone_number: request.parameters()["phone_number"] as! String, password: request.parameters()["password"] as! String))
                }
                
                completionHandler(response)
        }
    }
}
