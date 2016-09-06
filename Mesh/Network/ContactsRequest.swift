//
//  ContactsRequest.swift
//  Mesh
//
//  Created by Christopher Truman on 9/5/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Alamofire
import Contacts

struct ContactsRequest : AuthenticatedRequest {
    let path = "contacts", method = HTTPMethod.get
}

struct ContactsSaveRequest : AuthenticatedRequest {
    let path = "contacts", method = HTTPMethod.put
    
    let contacts : [CNContact]
    
    func parameters() -> [String : Any] { return ["contacts" : contacts.map({
        return ["phone_number": $0.phoneNumbers[safe: 0]?.value.value(forKey: "digits") as? String ?? "",
                "first_name": $0.givenName,
                "last_name": $0.familyName,
                "email": $0.emailAddresses[safe: 0]?.value ?? ""]
        })]
    }
}

