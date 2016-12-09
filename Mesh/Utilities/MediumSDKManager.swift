//
//  MediumSDKManager.swift
//
//
//

import SafariServices

extension Notification.Name { static let medium = NSNotification.Name("Medium") }

public class MediumSDKManager: NSObject, SFSafariViewControllerDelegate {

    public static let sharedInstance = MediumSDKManager()

    private let baseURL = "https://api.medium.com/v1"
    private var credentialsJSON: JSONDictionary?
    private var controller: UIViewController?
    private var completionHandler: ((Bool, String) -> Void)?

    public func doOAuthMedium(controller: UIViewController, completionHandler: @escaping (Bool, String) -> Void) {
        let clientID = MainBundle.object(forInfoDictionaryKey: "MediumClientID") as! String
        let authorizeURL = "https://medium.com/m/oauth/authorize"
        let callbackURL = MainBundle.object(forInfoDictionaryKey: "MediumCallbackURL") as! String

        // Specify the scope of public functions your app utilizes, options: basicProfile, publishPost, and listPublications. Extended scope "uploadImage" by default can't be requested by an application.
        let scope = "basicProfile"
        let state: String = UserResponse.current!._id
        let url = authorizeURL + "?client_id=\(clientID)&redirect_uri=\(callbackURL)&response_type=code&scope=\(scope)&state=\(state)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(redirect(notification:)), name: .medium, object: nil)
        
        self.completionHandler = completionHandler
        self.controller = controller
        controller.navigationController?.safari(url, push: false, delegate: self)
    }
    
    func redirect(notification: Notification) {
        completionHandler?(true, "mediumIsAuthorized"); completionHandler = nil
        controller?.dismiss()
        StandardDefaults.set(true, forKey: "mediumIsAuthorized")
        //guard let url = notification.object as? URL else { return }
        //TODO: parse url query strings
    }

    static func isAuthorized() -> Bool { return StandardDefaults.bool(forKey: "mediumIsAuthorized") }

    public func signOutMedium(completionHandler: ((Bool, String) -> Void) = {_, _ in }) {
        if StandardDefaults.bool(forKey: "mediumIsAuthorized") {
            StandardDefaults.set(false, forKey: "mediumIsAuthorized")
            completionHandler(true, "Signed out")
        } else { completionHandler(false, "Already signed out") }
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        completionHandler?(false, "User cancelled"); completionHandler = nil
    }
    
}
