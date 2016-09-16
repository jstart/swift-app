//
//  ImportProfile.swift
//  Mesh
//
//  Created by Christopher Truman on 9/14/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import Fabric
import TwitterKit
import GoogleSignIn
import Google
import LinkedinSwift

typealias PrefillResponse = (first_name: String, last_name: String, title: String, company: String, image_url: String)

struct TwitterProfile {
    
    static var imageURL: String?
    
    static func prefillImage(_ completion: @escaping ((PrefillResponse) -> Void)) {
        if let imageURL = TwitterProfile.imageURL {
            completion(PrefillResponse("", "", "", "", imageURL))
        } else {
            TwitterProfile.prefill(completion)
        }
    }
    
    static func prefill(_ completion: @escaping ((PrefillResponse) -> Void)) {
        Fabric.with([Twitter.self])
        Twitter.sharedInstance().logIn {(session, error) in
            guard session != nil else { return }
            let client = TWTRAPIClient.withCurrentUser()
            client.loadUser(withID: client.userID!, completion: { user, error in
                guard let user = user else { completion(("","","","","")); return }
                let nameSplit = user.name.components(separatedBy: " ")
                let first_name = nameSplit[safe: 0] ?? ""
                let last_name = nameSplit[safe: 1] ?? ""
                let imageURL = user.profileImageURL.replace("_reasonably_small", with: "")
                TwitterProfile.imageURL = imageURL
                completion(PrefillResponse(first_name, last_name, "", "", imageURL))
            })
        }
    }
}

class GoogleProfile : NSObject, GIDSignInDelegate {
    static let shared = GoogleProfile()
    static var imageURL: String?
    static var completion: ((PrefillResponse) -> Void)?
    static var imageCompletion: ((PrefillResponse) -> Void)?

    func prefillImage(_ completion: @escaping ((PrefillResponse) -> Void)) {
        if let imageURL = GoogleProfile.imageURL {
            completion(PrefillResponse("","","","", imageURL))
        } else {
            GoogleProfile.imageCompletion = completion; login()
        }
    }
    
    func prefill(_ completion: @escaping ((PrefillResponse) -> Void)) {
        GoogleProfile.completion = completion; login()
    }
    
    func login() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
        GIDSignIn.sharedInstance().signIn()
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            let givenName = user.profile.givenName ?? ""
            let familyName = user.profile.familyName ?? ""
            //            let email = user.profile.email ?? ""
            let imageURL = user.profile.imageURL(withDimension: 2000)?.absoluteString ?? ""
            GoogleProfile.imageURL = imageURL
            GoogleProfile.completion?((givenName, familyName, "", "", imageURL))
            GoogleProfile.completion = nil
            GoogleProfile.imageCompletion?((givenName, familyName, "", "", imageURL))
            GoogleProfile.imageCompletion = nil
        } else {
            GoogleProfile.completion?(("", "", "", "", ""))
            GoogleProfile.completion = nil
            GoogleProfile.imageCompletion?(("", "", "", "", ""))
            GoogleProfile.imageCompletion = nil
            print("\(error.localizedDescription)")
        }
    }
}

struct LinkedInProfile {
    static var imageURL: String?

    static let linkedinHelper = LinkedinSwiftHelper(configuration: LinkedinSwiftConfiguration(clientId: "775eh4hg8ks2le", clientSecret: "HHTipcKAKIH1DtfK", state: "DLKDJF45DIWOERCM", permissions: ["r_basicprofile", "r_emailaddress"], redirectUrl: "http://google.com"))
    
    static func prefill(_ completion: @escaping ((PrefillResponse) -> Void)) {
        linkedinHelper.authorizeSuccess({ (lsToken) -> Void in
            linkedinHelper.requestURL("https://api.linkedin.com/v1/people/~:(id,first-name,last-name,location,positions,industry,headline,specialties,public-profile-url,email-address,num-connections,picture-urls::(original))?format=json", requestType: LinkedinSwiftRequestGet, success: { (response) -> Void in
//                let email = (response.jsonObject["email-address"] as? String) ?? ""
                let firstName = (response.jsonObject["firstName"] as? String) ?? ""
                let lastName = (response.jsonObject["lastName"] as? String) ?? ""
                let imageURL = (((response.jsonObject["pictureUrls"] as? [String:Any])?["values"] as? [String])?[safe: 0]) ?? ""
                LinkedInProfile.imageURL = imageURL
//                let industry = response.jsonObject["industry"]
//                let headline = response.jsonObject["headline"]
                let position = ((response.jsonObject["positions"] as? JSONDictionary)?["values"] as? JSONArray)?.first
                let title = position?["title"] as? String ?? ""
                let company = ((position?["company"] as? JSONDictionary)?["name"] as? String) ?? ""
                completion(PrefillResponse(firstName, lastName, title, company, imageURL))
            })
            }, error: { (error) -> Void in
                print(error)
            }, cancel: { () -> Void in
                //User Cancelled!
        })
    }
}
