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

struct Client {
    static var baseURL = "http://dev.mesh.tinderventures.com:1337/"
    
    static func upload(_ request : PhotoRequest, completionHandler: @escaping (DataResponse<Any>) -> Void) {
        let fullPath = baseURL + request.path

        Alamofire.upload(multipartFormData: { multipartFormData in
            //multipartFormData.append(request.file, withName: "picture")
            multipartFormData.append(request.file, withName: "picture", fileName: "file.jpg", mimeType: "image/jpeg")
            }, to: fullPath, method: .post, headers: request.headers(), encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: completionHandler).validate()
                    break
                case .failure:
                    break
                }
        })
    }
    
    static func execute(_ request : Request, completionHandler: @escaping (DataResponse<Any>) -> Void) {
        let fullPath = baseURL + request.path

        Alamofire.request(fullPath, method: request.method, parameters: request.parameters().count == 0 ? nil : request.parameters(), encoding: JSONEncoding(), headers: request.headers())
            .validate()
            .responseJSON { response in
                if request is LogoutRequest {
                    NotificationCenter.default.post(name: .logout, object: nil)
                }
                
                if let localizedDescription = response.result.error?.localizedDescription {
                    if localizedDescription.contains("401") {
                        NotificationCenter.default.post(name: .logout, object: nil)
                    }
                }
                
                if request is LoginRequest || request is AuthRequest || request is ProfileRequest {
                    guard let JSON = response.result.value as? JSONDictionary else { completionHandler(response); return }
                    UserResponse.current = UserResponse(JSON: JSON)
                    print(User(JSON: JSON))
                    UserDefaults.standard.set(JSON, forKey: "CurrentUser")
                    if request is AuthRequest || request is LoginRequest {
                        Token.persistToken(UserResponse.current?.token ?? "")
                        Token.persistLogin((phone_number: request.parameters()["phone_number"] as! String, password: request.parameters()["password"] as! String))
                        Keychain.deleteLogin()
                        let _ = Keychain.addLogin(phone: request.parameters()["phone_number"] as! String, password: request.parameters()["password"] as! String)
                    }
                }
                
                if request is TokenRequest {
                    guard let JSON = response.result.value as? JSONDictionary else { completionHandler(response); return }
                    Token.persistToken(JSON["token"] as? String ?? "")
                }
                
                completionHandler(response)
        }
    }
}
