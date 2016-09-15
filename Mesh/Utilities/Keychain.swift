//
//  Keychain.swift
//  Mesh
//
//  Created by Christopher Truman on 9/1/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import Security

struct Keychain {
    
    static func fetchLogin() -> (username: String, password: String)? {
        let query : [NSString : AnyObject] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : "Mesh" as CFString,
            kSecAttrLabel : "Mesh Password" as CFString,
            kSecReturnAttributes : kCFBooleanTrue,   // return dictionary in result parameter
            kSecReturnData : kCFBooleanTrue,          // include the password value
            kSecMatchLimit : kSecMatchLimitOne
        ]
        var result : AnyObject?
        let err = SecItemCopyMatching(query as CFDictionary, &result)
        if (err == errSecSuccess) {
            // on success cast the result to a dictionary and extract the
            // username and password from the dictionary.
            if let result = result as? [NSString : AnyObject],
            let username = result[kSecAttrAccount] as? String,
            let passdata = result[kSecValueData] as? Data,
            let password = NSString(data:passdata as Data, encoding:String.Encoding.utf8.rawValue) as? String {
                return (username, password)
            }
        } else if (err == errSecItemNotFound) {
            return nil
        } else {
            // probably a program error,
            // print and lookup err code (e.g., -50 = bad parameter)
        }
        return nil
    }
    
    static func addLogin(phone: String, password: String) -> OSStatus {
        let query : [NSString : AnyObject] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : "Mesh" as CFString,
            kSecAttrLabel : "Mesh Password"  as CFString,
            kSecAttrAccount : phone as CFString,
            kSecValueData : password.data(using: String.Encoding.utf8)! as CFData
        ]
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    static func deleteLogin() {
        let query : [NSString : AnyObject] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : "Mesh" as CFString,
            kSecAttrLabel : "Mesh Password"  as CFString
        ]
        SecItemDelete(query as CFDictionary)
    }
}
