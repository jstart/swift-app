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

import Starscream

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WebSocketDelegate {

    var window: UIWindow?
    let socket = WebSocket(url: URL(string: "ws://dev.mesh.tinderventures.com:2000/")!)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow()
        window?.tintColor = #colorLiteral(red: 0.2, green: 0.7843137255, blue: 0.9960784314, alpha: 1)

        Fabric.with([Twitter.self])

        if (Token.retrieveToken() != nil && Token.retrieveToken() != "") {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
            window?.rootViewController = vc
            let tab = window?.rootViewController as! UITabBarController
            tab.tabBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            let vc = JoinTableViewController(style: .grouped)
            window?.rootViewController = UINavigationController(rootViewController: vc)
        }

        socket.delegate = self
        socket.connect()

        window?.makeKeyAndVisible()

        return true
    }
    
    func websocketDidConnect(_ socket: WebSocket) {
        
    }
    func websocketDidDisconnect(_ socket: WebSocket, error: NSError?){
        print(error)
    }
    func websocketDidReceiveMessage(_ socket: WebSocket, text: String){
        
    }
    func websocketDidReceiveData(_ socket: WebSocket, data: Data){
        
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

    override var canBecomeFirstResponder: Bool { return true }
    
    override var keyCommands: [UIKeyCommand]? {
        return [UIKeyCommand(input: "l", modifierFlags: [.command, .alternate], action: #selector(logout), discoverabilityTitle: "Convenience")]
    }
    
    func logout(command: UIKeyCommand) {
        Token.persistToken("")
        Token.persistLogin((phone_number: "", password: ""))
        UserResponse.currentUser = nil
        let vc = JoinTableViewController(style: .grouped)
        window?.rootViewController = UINavigationController(rootViewController: vc)
    }
}
