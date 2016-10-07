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

typealias PrefillResponse = (first_name: String, last_name: String, title: String, company: String, image_url: String)

struct TwitterProfile {
    static var imageURL: String?
    
    static func prefillImage(_ completion: @escaping ((PrefillResponse?) -> Void)) {
        if let imageURL = TwitterProfile.imageURL {
            completion(PrefillResponse("", "", "", "", imageURL))
        } else {
            TwitterProfile.prefill(completion)
        }
    }
    
    static func prefill(_ completion: @escaping ((PrefillResponse?) -> Void)) {
        Twitter.sharedInstance().logIn {(session, error) in
            guard session != nil else { completion(nil); return }
            let client = TWTRAPIClient.withCurrentUser()
            client.loadUser(withID: client.userID!, completion: { user, error in
                guard let user = user else { completion(nil); return }
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
    static var completion: ((PrefillResponse?) -> Void)? = { _ in }
    static var imageCompletion: ((PrefillResponse?) -> Void)? = { _ in }

    func prefillImage(_ completion: @escaping ((PrefillResponse?) -> Void)) {
        if let imageURL = GoogleProfile.imageURL {
            completion(PrefillResponse("","","","", imageURL))
        } else {
            GoogleProfile.imageCompletion = completion; login()
        }
    }
    
    func prefill(_ completion: @escaping ((PrefillResponse?) -> Void)) {
        GoogleProfile.completion = completion; login()
    }
    
    func login() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    static func isLoggedIn() -> Bool { return GIDSignIn.sharedInstance().hasAuthInKeychain() }
    
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
            GoogleProfile.completion?(nil)
            GoogleProfile.completion = nil
            GoogleProfile.imageCompletion?(nil)
            GoogleProfile.imageCompletion = nil
            print("\(error.localizedDescription)")
        }
    }
}

struct LinkedInProfile {
    static var imageURL: String?
    
    static func prefill(_ completion: @escaping ((PrefillResponse?) -> Void)) {
        LinkedInSwiftHelper.authorize(inViewController: UIApplication.shared.delegate!.window!!.rootViewController!, success: { token in
            LinkedInSwiftHelper.request(url: "https://api.linkedin.com/v1/people/~:(id,first-name,last-name,location,positions,industry,headline,specialties,public-profile-url,email-address,num-connections,picture-urls::(original))?format=json", requestMethod: "GET", success: { response in
                //                let email = (response.jsonObject["email-address"] as? String) ?? ""
                let firstName = (response["firstName"] as? String) ?? ""
                let lastName = (response["lastName"] as? String) ?? ""
                let imageURL = (((response["pictureUrls"] as? [String:Any])?["values"] as? [String])?[safe: 0]) ?? ""
                LinkedInProfile.imageURL = imageURL
                //                let industry = response.jsonObject["industry"]
                //                let headline = response.jsonObject["headline"]
                let position = ((response["positions"] as? JSONDictionary)?["values"] as? JSONArray)?.first
                let title = position?["title"] as? String ?? ""
                let company = ((position?["company"] as? JSONDictionary)?["name"] as? String) ?? ""
                DispatchQueue.main.async { completion(PrefillResponse(firstName, lastName, title, company, imageURL)) }
                }, failure: { _ in
                    completion(nil)
                })
            }, error: { (error) -> Void in
                    completion(nil)
                }, cancel: { () -> Void in
                    completion(nil)
        })
    }
}
