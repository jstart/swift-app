//
//  LIALinkedInApplication.swift
//  
//  Created by Christopher Truman on 9/26/16.
//

import Foundation

struct LIALinkedInApplication {
    
    static let shared = LIALinkedInApplication(redirectURL: "https://www.google.com", clientId: "775eh4hg8ks2le", clientSecret: "HHTipcKAKIH1DtfK", state: "DLKDJF45DIWOERCM", grantedAccess: ["r_basicprofile", "r_emailaddress"])

/** ************************************************************************************************ **
 * @name Attributes
 ** ************************************************************************************************ **/

/**
 * Has to be a http or https url (required by LinkedIn), but other than that, the endpoint doesn't have to respond anything. The library only uses the endpoint to know when to intercept calls in the UIWebView.
 **/
    var redirectURL: String

/**
 * The id which is provided by LinkedIn upon registering an application.
 **/
    var clientId: String

/**
 * The secret which is provided by LinkedIn upon registering an application.
 **/
    var clientSecret: String

/**
 * The state used to prevent Cross Site Request Forgery. Should be something that is hard to guess.
 **/
    var state: String

/**
 * An array telling which access the application would like to be granted by the enduser. See full list here: http://developer.linkedin.com/documents/authentication.
 **/
    var grantedAccess: [String]

    var grantedAccessString: String { return (grantedAccess as NSArray).componentsJoined(by: "%20") }

}
