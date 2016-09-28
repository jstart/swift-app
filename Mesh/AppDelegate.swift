//
//  AppDelegate.swift
//  Mesh
//
//  Created by Christopher Truman on 8/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit
import Crashlytics
import GoogleSignIn
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(); window?.tintColor = #colorLiteral(red: 0.2, green: 0.7843137255, blue: 0.9960784314, alpha: 1); appearance()

        if let path = MainBundle.path(forResource: "GoogleService-Info", ofType: "plist") {
            let info = NSDictionary(contentsOfFile: path)!; GIDSignIn.sharedInstance().clientID = info["CLIENT_ID"] as! String
        }
        
        Fabric.with([Crashlytics.self, Twitter.self])
        
        NotificationCenter.default.addObserver(self, selector: #selector(logout(_:)), name: .logout, object: nil)

        if (Keychain.fetchLogin() != nil) {
            guard let JSON = StandardDefaults["CurrentUser"] as? JSONDictionary else { logout(); return true}
            UserResponse.current = UserResponse(JSON: JSON)
            LaunchData.fetchLaunchData()
            
            window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        } else {
            window?.rootViewController = LaunchViewController().withNav()
        }
        
        window?.makeKeyAndVisible()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let source = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        if source == "com.apple.SafariViewService" { OAuthSwift.handleOpenURL(url); return true }
        if Twitter.sharedInstance().application(app, open: url, options: options) { return true }
        if LinkedInSwiftHelper.shouldHandle(url) { return LinkedInSwiftHelper.application(app, openURL: url as NSURL, sourceApplication: source!, annotation: annotation) }
        return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: source, annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) { CoreData.saveContext() }
    func applicationWillTerminate(_ application: UIApplication) { CoreData.saveContext() }
    
    func appearance() {
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.proxima(ofSize: 17), NSForegroundColorAttributeName: #colorLiteral(red: 0.2666666667, green: 0.2666666667, blue: 0.2666666667, alpha: 1)]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = .proxima(ofSize: 20)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.proxima(ofSize: 17)], for: .normal)
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).font = .regularProxima(ofSize: 17)
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).font = .proxima(ofSize: 17)
        UISwitch.appearance().onTintColor = Colors.brand
        UITabBar.appearance().tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }

    override var canBecomeFirstResponder: Bool { return true }
    override var keyCommands: [UIKeyCommand]? { return [UIKeyCommand(input: "l", modifierFlags: [.command, .alternate], action: #selector(logout), discoverabilityTitle: "Convenience")] }
    
    func logout(_ command: UIKeyCommand? = nil) {
        Token.deleteToken(); Token.deleteLogin(); Keychain.deleteLogin(); CoreData.delete()
        UserResponse.current = nil; UserResponse.connections = []; UserResponse.messages = []; CardResponse.cards = []
        URLCache.shared.removeAllCachedResponses()
        
        MediumSDKManager.sharedInstance.signOutMedium(completionHandler: {_,_ in })
        GIDSignIn.sharedInstance().signOut()
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            Twitter.sharedInstance().sessionStore.logOutUserID(userID)
        }
        
        window?.rootViewController = LaunchViewController().withNav()
    }
}
