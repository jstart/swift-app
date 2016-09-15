//
//  AppDelegate.swift
//  Mesh
//
//  Created by Christopher Truman on 8/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Google
import GoogleSignIn
import LinkedinSwift

//import Starscream

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate { //, WebSocketDelegate {

    var window: UIWindow?
    //let socket = WebSocket(url: URL(string: "ws://dev.mesh.tinderventures.com:2000/")!)
    /*func websocketDidConnect(_ socket: WebSocket) { }
     func websocketDidDisconnect(_ socket: WebSocket, error: NSError?){ print(error) }
     func websocketDidReceiveMessage(_ socket: WebSocket, text: String){ }
     func websocketDidReceiveData(_ socket: WebSocket, data: Data){ }*/
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow()
        window?.tintColor = #colorLiteral(red: 0.2, green: 0.7843137255, blue: 0.9960784314, alpha: 1)
        window?.backgroundColor = .white
        appearance()
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")

        if TARGET_IPHONE_SIMULATOR == 0 { Fabric.with([Crashlytics.self]) }
        NotificationCenter.default.addObserver(self, selector: #selector(logout(_:)), name: .logout, object: nil)

        if (Keychain.fetchLogin() != nil) {
            guard let JSON = UserDefaults.standard["CurrentUser"] as? JSONDictionary else { logout(UIKeyCommand()); return true}
            UserResponse.current = UserResponse(JSON: JSON)
            
            LaunchData.fetchLaunchData()
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
            window?.rootViewController = vc
            let tab = window?.rootViewController as! UITabBarController
            tab.tabBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            let vc = LaunchViewController()
            window?.rootViewController = vc.withNav()
        }

        //socket.delegate = self
        //socket.connect()

        window?.makeKeyAndVisible()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if LinkedinSwiftHelper.shouldHandle(url) {
            return LinkedinSwiftHelper.application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        return GIDSignIn.sharedInstance().handle(url as URL!,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        CoreData.saveContext()
    }
//    func applicationDidEnterBackground(_ application: UIApplication) { }
//    func applicationWillEnterForeground(_ application: UIApplication) { }
    func applicationDidBecomeActive(_ application: UIApplication) { }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreData.saveContext()
    }
    
    func appearance() {
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.proxima(ofSize: 17)]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = .proxima(ofSize: 20)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.proxima(ofSize: 17)], for: .normal)
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).font = .regularProxima(ofSize: 17)
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).font = .proxima(ofSize: 17)
    }

    override var canBecomeFirstResponder: Bool { return true }
    override var keyCommands: [UIKeyCommand]? {
        return [UIKeyCommand(input: "l", modifierFlags: [.command, .alternate], action: #selector(logout), discoverabilityTitle: "Convenience")]
    }
    
    func logout(_ command: UIKeyCommand) {
        Token.persistToken("")
        Token.persistLogin((phone_number: "", password: ""))
        Keychain.deleteLogin()
        UserResponse.current = nil
        UserResponse.connections = []
        UserResponse.messages = []
        CardResponse.cards = []
        URLCache.shared.removeAllCachedResponses()
        let vc = LaunchViewController()
        window?.rootViewController = vc.withNav()
        CoreData.delete()
    }
}
