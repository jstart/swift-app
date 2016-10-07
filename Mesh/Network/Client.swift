//
//  Client.swift
//  Mesh
//
//  Created by Christopher Truman on 8/9/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire
import Crashlytics

typealias JSONDictionary = [String : Any]
typealias JSONArray = [JSONDictionary]

protocol Request {
    var path : String { get }
    var method : HTTPMethod { get }
    func parameters() -> JSONDictionary
    func headers() -> [String : String]
 }

protocol AuthenticatedRequest : Request {}
extension AuthenticatedRequest { func headers() -> [String : String] { return ["token" : Token.retrieveToken() ?? ""] } }

extension Request {
    func parameters () -> JSONDictionary {
        let mirrorProperties = Mirror(reflecting: self).children
        var parameters = [String: Any]()
        mirrorProperties.forEach({
            guard $0.label! != "method" && $0.label! != "path" else { return }; parameters[$0.label!] = $0.value
        })
        if parameters.values.count > 0 { return parameters }; return [:]
    }
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
                    upload.responseJSON(completionHandler: completionHandler).validate(); break
                case .failure: break
                }
        })
    }
    
    static func execute(_ request : Request, complete: @escaping ((DataResponse<Any>) -> Void) = { _ in } ) {
        let fullPath = baseURL + request.path

        Alamofire.request(fullPath, method: request.method, parameters: request.parameters().count == 0 ? nil : request.parameters(), encoding: request.method == .post || request.method == .put ? JSONEncoding() : URLEncoding(), headers: request.headers())
            .validate()
            .responseJSON { response in
                if request is LogoutRequest { NotificationCenter.default.post(name: .logout, object: nil) }
                
                if let errorText = response.result.error?.localizedDescription { if errorText.contains("401") { NotificationCenter.default.post(name: .logout, object: nil) } }
                
                if request is LoginRequest || request is AuthRequest || request is ProfileRequest {
                    guard let JSON = response.result.value as? JSONDictionary else { complete(response); return }
                    UserResponse.current = UserResponse.create(JSON)
                    StandardDefaults.set(JSON, forKey: "CurrentUser")
                    Crashlytics.sharedInstance().setUserName(UserResponse.current?.fullName()); Crashlytics.sharedInstance().setUserIdentifier(UserResponse.current?._id)
                    if request is AuthRequest || request is LoginRequest {
                        Token.persistToken(UserResponse.current?.token ?? "")
                        Token.persistLogin((phone_number: UserResponse.current!.phone_number!, password: request.parameters()["password"] as! String))
                        Keychain.deleteLogin()
                        let _ = Keychain.addLogin(phone: UserResponse.current!.phone_number!, password: request.parameters()["password"] as! String)
                    }
                }
                
                if request is TokenRequest { Token.persistToken((response.result.value as? JSONDictionary)?["token"] as? String ?? "") }
                
                complete(response)
        }
    }
}
