//
//  LinkedInSwiftHelper.swift
//  Mesh
//
//  Created by Christopher Truman on 9/26/16.
//  Copyright © 2016 Tinder. All rights reserved.
//
//
import Foundation
import UIKit
import Alamofire

struct LIAccessToken { let accessToken: String, expireDate: TimeInterval, isFromMobileSDK: Bool }

struct LinkedInSwiftHelper {
    static var accessToken: LIAccessToken?
    private static var application: LIALinkedInApplication = .shared
    
    static let LINKEDIN_TOKEN_KEY = "linkedin_token", LINKEDIN_EXPIRATION_KEY = "linkedin_expiration", LINKEDIN_CREATION_KEY = "linkedin_token_created_at"
    
    static func getAccessToken(authorizationCode: String, success: @escaping ((JSONDictionary) -> Void), failure: @escaping ((Error) -> Void)) {
        let accessTokenUrl = "https://www.linkedin.com/uas/oauth2/accessToken?grant_type=authorization_code&code=\(authorizationCode)&redirect_uri=\(application.redirectURL.URLEncoded)&client_id=\(application.clientId)&client_secret=\(application.clientSecret)"
        
        Alamofire.request(accessTokenUrl, method: .post, parameters: nil, encoding: JSONEncoding())
            .validate()
            .responseJSON { response in
                if let error = response.result.error { failure(error); return }
                if let responseJSON = response.result.value as? JSONDictionary { storeCredentials(responseJSON); success(responseJSON) }
        }
    }
    
    static func storeCredentials(_ response: JSONDictionary) {
        let accessToken = response["access_token"], expiration = response["expires_in"] as! Double
        
        StandardDefaults.set(accessToken, forKey: LINKEDIN_TOKEN_KEY)
        StandardDefaults.set(Date().timeIntervalSince1970 + expiration, forKey: LINKEDIN_EXPIRATION_KEY)
        StandardDefaults.set(Date().timeIntervalSince1970, forKey: LINKEDIN_CREATION_KEY)
        LinkedInSwiftHelper.accessToken = LIAccessToken(accessToken: StandardDefaults.object(forKey: LINKEDIN_TOKEN_KEY) as! String, expireDate: StandardDefaults.object(forKey: LINKEDIN_EXPIRATION_KEY) as! TimeInterval, isFromMobileSDK: false)
    }
    
    static func authorize(inViewController: UIViewController, success: @escaping ((LIAccessToken) -> Void), error: @escaping ((Error) -> Void), cancel: @escaping ((Void) -> Void)) {
        if accessToken != nil { success(accessToken!) }
        else {
            // removing LinkedIn SDK because it causes warnings and prevents bitcode compilation.  Also probably not that valuable to let people auth through the linkedin app
//            if isLinkedInInstalled {
//                if LISDKSessionManager.sharedInstance().session.accessToken != nil {
//                    let session = LISDKSessionManager.sharedInstance().session!
//                    accessToken = LIAccessToken(accessToken: session.accessToken.accessTokenValue, expireDate: session.accessToken.expiration.timeIntervalSince1970, isFromMobileSDK: true)
//                    success(accessToken!)
//                } else {
//                    LISDKSessionManager.createSession(withAuth: application.grantedAccess, state: application.state, showGoToAppStoreDialog: true, successBlock: { state in
//                        guard let session = LISDKSessionManager.sharedInstance().session else { cancel(); return }
//                        accessToken = LIAccessToken(accessToken: session.accessToken.accessTokenValue, expireDate: session.accessToken.expiration.timeIntervalSince1970, isFromMobileSDK: true)
//                        success(accessToken!)
//                    }, errorBlock: { linkedInError in
//                        if ((linkedInError! as NSError).code == 3) { cancel() } else { error(linkedInError!) }
//                    })
//                }
//            }
//            else {
                let authVC = LIALinkedInAuthorizationViewController()
                authVC.success = { code in getAccessToken(authorizationCode: code, success: { response in success(accessToken!) }, failure: error) }
                authVC.failure = error; authVC.cancel = cancel
                inViewController.present(authVC.withNav())
            }
//        }
    }
    
    static func request(url: String, requestMethod: String, success: @escaping ((JSONDictionary) -> Void), failure: @escaping ((Error) -> Void)) {
        if let token = accessToken {
//            if token.isFromMobileSDK {
//                LISDKAPIHelper.sharedInstance().getRequest(url, success: { response in
//                    if let data = response?.data.data(using: String.Encoding.utf8) {
//                        do {
//                            let responseObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
//                            success(responseObject as! JSONDictionary)
//                        } catch { failure(error) }
//                    } }, error: { error in failure(error!) }); return
//            }
            
            Alamofire.request(url, method: .get, parameters: ["oauth2_access_token" : token.accessToken], encoding: URLEncoding())
                .validate().responseJSON { response in
                    if let error = response.result.error { failure(error); return }
                    if let responseJSON = response.result.value as? JSONDictionary { success(responseJSON) }
            }
        }
    }

    static var isLinkedInInstalled : Bool { return UIApplication.shared.canOpenURL(URL(string: "linkedin://")!) }
    static func shouldHandle(_ url: URL) -> Bool {
        return false//        return isLinkedInInstalled && LISDKCallbackHandler.shouldHandle(url)
    }
    static func application(_ application: UIApplication, openURL: NSURL, sourceApplication: String, annotation: Any) -> Bool {
        return false//isLinkedInInstalled && LISDKCallbackHandler.application(application, open: openURL as URL!, sourceApplication: sourceApplication, annotation: annotation)
    }

}
