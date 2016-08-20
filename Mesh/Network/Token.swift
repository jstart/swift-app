//
//  Token.swift
//  Mesh
//
//  Created by Christopher Truman on 8/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation

struct Token {
    static func persistToken(_ token: String){
        UserDefaults.standard.setValue(token, forKey: "token")
    }
    
    static func retrieveToken() -> String? {
        return UserDefaults.standard.value(forKey: "token") as? String
    }
    
    static func persistLogin(_ login: (phone_number: String, password: String)){
        UserDefaults.standard.setValue(login.phone_number, forKey: "phone_number")
        UserDefaults.standard.setValue(login.password, forKey: "password")
    }
    
    static func retrieveLogin() -> (phone_number: String?, password: String?) {
        return (UserDefaults.standard.value(forKey: "phone_number") as? String,
                UserDefaults.standard.value(forKey: "password") as? String)
    }
    
}
