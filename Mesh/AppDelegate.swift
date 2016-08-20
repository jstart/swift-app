//
//  AppDelegate.swift
//  Mesh
//
//  Created by Christopher Truman on 8/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow()
        
        if (Token.retrieveToken() != nil && Token.retrieveToken() != "") {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
            window?.rootViewController = vc
            let tab = window?.rootViewController as! UITabBarController
            tab.tabBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            let vc = JoinTableViewController(style: .grouped)
            window?.rootViewController = UINavigationController(rootViewController: vc)
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}
