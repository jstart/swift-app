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
    
}
