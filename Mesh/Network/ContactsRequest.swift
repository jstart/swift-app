//
//  ContactsRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 9/5/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire
import Contacts

struct ContactsRequest : AuthenticatedRequest { let path = "contacts", method = HTTPMethod.get }

struct ContactsSaveRequest : AuthenticatedRequest {
    let path = "contacts", method = HTTPMethod.put
    
    let contacts : [CNContact]
    
    func parameters() -> JSONDictionary {
        var contacts = [JSONDictionary]()
        self.contacts.forEach({
            contacts.append(["phone_number": $0.phoneNumberStrings?.first ?? "",
                    "first_name": $0.givenName, "last_name": $0.familyName,
                    "email": $0.emailStrings?.first ?? ""])
        })
        return ["contacts" : contacts]
    }
}

