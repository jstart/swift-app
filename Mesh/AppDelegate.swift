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
import RealmSwift

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
            UserResponse.current = UserResponse.create(JSON)
            LaunchData.fetchLaunchData()
            
            window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        } else {
            window?.rootViewController = LaunchViewController().withNav()
        }
        SocketHandler.startListening()
        
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        SocketHandler.startListening()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketHandler.stopListening()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let source = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        if url.absoluteString.contains("medium") { NotificationCenter.default.post(name: .medium, object: url); return true }
        if Twitter.sharedInstance().application(app, open: url, options: options) { return true }
        if LinkedInSwiftHelper.shouldHandle(url) { return LinkedInSwiftHelper.application(app, openURL: url as NSURL, sourceApplication: source!, annotation: annotation) }
        return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: source, annotation: annotation)
    }
    
    func appearance() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.proxima(ofSize: 17), NSForegroundColorAttributeName: #colorLiteral(red: 0.2666666667, green: 0.2666666667, blue: 0.2666666667, alpha: 1)]
        //UITextField.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.8941176471, alpha: 1)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = .proxima(ofSize: 20)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.proxima(ofSize: 17)], for: .normal)
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).font = .regularProxima(ofSize: 17)
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).font = .proxima(ofSize: 17)
        UISwitch.appearance().onTintColor = Colors.brand
        UITabBar.appearance().tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        //UITableView.appearance().backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
    }

    override var canBecomeFirstResponder: Bool { return true }
    override var keyCommands: [UIKeyCommand]? { return [UIKeyCommand(input: "l", modifierFlags: [.command, .alternate], action: #selector(logout), discoverabilityTitle: "Convenience")] }
    
    func logout(_ command: UIKeyCommand? = nil) {
        Token.deleteToken(); Token.deleteLogin(); Keychain.deleteLogin(); RealmUtilities.deleteAll()
        UserResponse.current = nil; UserResponse.connections = []; UserResponse.messages = []; UserResponse.cards = []
        URLCache.shared.removeAllCachedResponses()
        
        MediumSDKManager.sharedInstance.signOutMedium(completionHandler: {_,_ in })
        GIDSignIn.sharedInstance().signOut()
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            Twitter.sharedInstance().sessionStore.logOutUserID(userID)
        }
        Crashlytics.sharedInstance().setUserName(nil); Crashlytics.sharedInstance().setUserIdentifier(nil)
        
        window?.rootViewController = LaunchViewController().withNav()
    }
}
