//
//  MediumSDKManager.swift
//
//
//  Created by drinkius on 20/05/16.
//
//

import OAuthSwift
import Alamofire

public class MediumSDKManager: NSObject {

    public static let sharedInstance = MediumSDKManager()
    private override init() {}

    private let baseURL = "https://api.medium.com/v1"
    private var oauthswift: OAuth2Swift!
    private var credential: OAuthSwiftCredential!
    private var credentialsJSON: JSONDictionary?

    public func doOAuthMedium(completionHandler: @escaping (String, String) -> Void) {

        let clientID = MainBundle.object(forInfoDictionaryKey: "MediumClientID") as! String
        let clientSecret = MainBundle.object(forInfoDictionaryKey: "MediumClientSecret") as! String

        let authorizeURL = "https://medium.com/m/oauth/authorize"
        let accessTokenUrl = baseURL + "/tokens"
        let callbackURL = MainBundle.object(forInfoDictionaryKey: "MediumCallbackURL") as! String

        // Specify the scope of public functions your app utilizes, options: basicProfile,publishPost, and listPublications. Extended scope "uploadImage" by default can't be requested by an application.
        let scope = "basicProfile"

        let oauthswift = OAuth2Swift(consumerKey: clientID, consumerSecret: clientSecret, authorizeUrl: authorizeURL, accessTokenUrl: accessTokenUrl, responseType: "code")
        oauthswift.authorize_url_handler = SafariURLHandler(viewController: (UIApplication.shared.delegate?.window??.rootViewController)!)
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL(URL(string: callbackURL)!, scope: scope, state: state, success: {
            credential, response, parameters in

            self.credential = credential

            print("Token \(self.credential.oauth_token)")
            print("Refresh token \(self.credential.oauth_refresh_token)")

            StandardDefaults.set(true, forKey: "mediumIsAuthorized")
            StandardDefaults.set(self.credential.oauth_token, forKey: "mediumToken")
            StandardDefaults.set(self.credential.oauth_refresh_token, forKey: "mediumRefreshToken")

            self.ownCredentialsRequest() { state, response in
                if state != "error" {
                    completionHandler("success", StandardDefaults.object(forKey: "mediumToken")! as! String)
                } else {
                    completionHandler("error", "Logged in but couldn't fetch your user details")
                }
            }
            }, failure: { error in
                StandardDefaults.set(false, forKey: "mediumIsAuthorized")
                completionHandler("error", "Login failed")
        })
    }

    static func isAuthorized() -> Bool { return StandardDefaults.bool(forKey: "mediumIsAuthorized") }

    public func getUserID(completionHandler: (String, String) -> Void) {
        if StandardDefaults.bool(forKey: "mediumIsAuthorized") {
            let response = StandardDefaults.object(forKey: "mediumUserID")! as! String
            completionHandler("success", response)
        } else {
            completionHandler("error", "Not authorized on Medium")
        }
    }

    public func getToken(completionHandler: (String, String) -> Void) {
        if StandardDefaults.bool(forKey: "mediumIsAuthorized") {
            let response = StandardDefaults.object(forKey: "mediumToken")! as! String
            completionHandler("success", response)
        } else {
            completionHandler("error", "Not authorized on Medium")
        }
    }

    public func signOutMedium(completionHandler: (String, String) -> Void) {
        if StandardDefaults.bool(forKey: "mediumIsAuthorized") {
            StandardDefaults.set(false, forKey: "mediumIsAuthorized")
            StandardDefaults.set(nil, forKey: "mediumToken")
            StandardDefaults.set(nil, forKey: "mediumRefreshToken")

            completionHandler("success", "Signed out")
        } else { completionHandler("error", "Already signed out") }
    }

    // Completion handler returns state: success/failure, and user ID as a string if present
    public func ownCredentialsRequest(completionHandler: @escaping (String, String) -> Void) {
        if StandardDefaults.bool(forKey: "mediumIsAuthorized") {
            let token = StandardDefaults.object(forKey: "mediumToken")!
            let headers = ["Authorization": "Bearer \(token)", "Content-Type": "application/json", "Accept": "application/json", "Accept-Charset": "utf-8"]

            Alamofire.request(baseURL + "/me", method: .get, headers: headers)
                .responseJSON { response in
                    if let JSON = response.result.value as? JSONDictionary {
                        let credentialsJSON = JSON["data"] as? JSONDictionary
                        if credentialsJSON != nil {
                            let userID = credentialsJSON?["id"] as? String
                            self.credentialsJSON = credentialsJSON
                            if userID != nil {
                                StandardDefaults.set(userID, forKey: "mediumUserID")
                                completionHandler("success", StandardDefaults.object(forKey: "mediumUserID")! as! String)
                            } else { completionHandler("error", "Couldn't fetch your User ID") }
                        }
                    } else { completionHandler("error", "Connection error") }
            }
        } else { completionHandler("error", "Not authorized on Medium") }
    }
    
}
