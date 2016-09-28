//
//  Token.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation

struct Token {
    static let defaults = StandardDefaults
    static func persistToken(_ token: String) {
        defaults.setValue(token, forKey: "token")
    }
    
    static func deleteToken() {
        defaults.setValue(nil, forKey: "token")
    }
    
    static func retrieveToken() -> String? {
        return defaults["token"] as? String
    }
    
    static func persistLogin(_ login: (phone_number: String, password: String)) {
        defaults.setValue(login.phone_number, forKey: "phone_number")
        defaults.setValue(login.password, forKey: "password")
    }
    
    static func deleteLogin() {
        defaults.setValue(nil, forKey: "phone_number"); defaults.setValue(nil, forKey: "password")
    }
    
    static func retrieveLogin() -> (phone_number: String?, password: String?) {
        return (defaults["phone_number"] as? String, defaults["password"] as? String)
    }
}
